//
//  MasteryViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

struct MasteryBreakdownRow: Identifiable, Hashable {
    let name: String
    let earnedPoints: Int

    var id: String { name }
}

struct MasteryRankProgress {
    let rank: Int
    let currentXP: Int
    let xpForCurrentRank: Int
    let xpForNextRank: Int

    var fraction: Double {
        let span = Double(xpForNextRank - xpForCurrentRank)
        guard span > 0 else { return 1 }
        return Double(currentXP - xpForCurrentRank) / span
    }

    var xpToNextRank: Int { xpForNextRank - currentXP }
}

@Observable
final class MasteryViewModel {
    // MARK: - Object Properties
    private let profileRepository: ProfileRepository
    private let catalogRepository: CatalogRepository
    let errorManager: ErrorManager
    
    private(set) var summary: MasteryCatalogSummary?
    private(set) var breakdownSections: [[MasteryBreakdownRow]] = []

    private(set) var isLoading: Bool = false

    // MARK: - Computed Properties
    var categories: [CatalogContainerSummary] {
        summary?.categories ?? []
    }
    var nonItemCategories: [MasteryCategorySummary] {
        summary?.nonItemCategories ?? []
    }

    var earnedMasteryXP: Int {
        categories.reduce(0) { $0 + $1.earnedMasteryPoints }
            + nonItemCategories.reduce(0) { $0 + $1.earnedMasteryPoints }
    }

    var rankProgress: MasteryRankProgress {
        Self.rankProgress(forXP: earnedMasteryXP)
    }

    var obtainableItemsRemaining: Int {
        categories.reduce(0) { $0 + $1.obtainableRemainingCount }
    }

    var breakdownTotal: Int {
        breakdownSections.flatMap(\.self).reduce(0) { $0 + $1.earnedPoints }
    }

    // MARK: - Init
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchCatalog(forceRefresh: Bool = false) async {
        isLoading = summary == nil
        defer {
            isLoading = false
        }

        do {
            if let profile = try? await profileRepository.getProfile(forceRefresh: forceRefresh) {
                summary = try await catalogRepository.syncMasterySummary(with: profile)
            } else {
                summary = try await catalogRepository.getMasterySummary()
            }
        } catch {
            errorManager.append(error)
        }
    }

    func loadBreakdown() async {
        guard breakdownSections.isEmpty else { return }
        do {
            let nodes = try await catalogRepository.getMasterySources(named: .nodes)
            let intrinsics = try await catalogRepository.getMasterySources(named: .intrinsics)
            let junctions = try await catalogRepository.getMasterySources(named: .junctions)
            breakdownSections = Self.makeBreakdownSections(
                categories: categories,
                nodes: nodes,
                intrinsics: intrinsics,
                junctions: junctions
            )
        } catch {
            errorManager.append(error)
        }
    }

    func makeCategoryDetailViewModel(for category: CatalogItemModel.Category) -> MasteryCategoryDetailViewModel {
        .init(category: category, catalogRepository: catalogRepository, errorManager: errorManager)
    }

    func makeSourceDetailViewModel(for categoryName: String) -> MasterySourceCategoryDetailViewModel {
        .init(categoryName: categoryName, catalogRepository: catalogRepository, errorManager: errorManager)
    }
    
    // MARK: - Helper Functions
    private static func rankProgress(forXP xp: Int) -> MasteryRankProgress {
        let legendaryCapRank = 30
        let legendaryCapXP = 2500 * legendaryCapRank * legendaryCapRank
        let legendaryRankXP = 147_500
        func cumulativeXP(for rank: Int) -> Int {
            guard rank > legendaryCapRank else { return 2500 * rank * rank }
            return legendaryCapXP + (rank - legendaryCapRank) * legendaryRankXP
        }
        var completedRanks = 0
        while cumulativeXP(for: completedRanks + 1) <= xp {
            completedRanks += 1
        }
        return MasteryRankProgress(
            rank: completedRanks,
            currentXP: xp,
            xpForCurrentRank: cumulativeXP(for: completedRanks),
            xpForNextRank: cumulativeXP(for: completedRanks + 1)
        )
    }

    // Groups every `CatalogItemModel.Category` and non-item source into the same
    // rows/order the in-game "Mastery Breakdown" panel uses, so the two can be
    // compared line by line. Every case is placed somewhere (see the "Other" section)
    // so the rows' total always equals `earnedMasteryXP` exactly.
    private static func makeBreakdownSections(
        categories: [CatalogContainerSummary],
        nodes: MasteryCategoryModel,
        intrinsics: MasteryCategoryModel,
        junctions: MasteryCategoryModel
    ) -> [[MasteryBreakdownRow]] {
        func points(for members: Set<CatalogItemModel.Category>) -> Int {
            categories
                .filter { members.contains($0.category) }
                .reduce(0) { $0 + $1.earnedMasteryPoints }
        }
        func points(in sources: [MasterySourceModel], where predicate: (MasterySourceModel) -> Bool) -> Int {
            sources
                .filter { $0.isMastered == true && predicate($0) }
                .reduce(0) { $0 + $1.mastery }
        }
        func row(_ name: String, _ points: Int) -> MasteryBreakdownRow {
            .init(name: name, earnedPoints: points)
        }

        let weapons = [
            row("Warframes", points(for: [.suits])),
            row("Primary Weapons", points(for: [.longGuns])),
            row("Secondary Weapons", points(for: [.pistols])),
            row("Melee Weapons", points(for: [.melee, .zaw])),
            row("Kitguns", points(for: [.kitgun]))
        ]

        let missionsAndIntrinsics = [
            row("Missions", points(in: nodes.sources) { !$0.name.contains("Steel Path") } + points(in: junctions.sources) { !$0.name.contains("Steel Path") }),
            row("Steel Path Missions", points(in: nodes.sources) { $0.name.contains("Steel Path") } + points(in: junctions.sources) { $0.name.contains("Steel Path") }),
            row("Railjack Intrinsics", points(in: intrinsics.sources) { $0.name.contains("Railjack") }),
            row("Drifter Intrinsics", points(in: intrinsics.sources) { $0.name.contains("Drifter") })
        ]

        let companions = [
            row("Sentinels", points(for: [.sentinels])),
            row("Sentinel Weapons", points(for: [.sentinelWeapons])),
            row("Companions", points(for: [.kubrowPets, .moa, .hound, .specialItems]))
        ]

        let archAndModular = [
            row("Archwing", points(for: [.spaceSuits])),
            row("Archgun", points(for: [.spaceGuns])),
            row("Archmelee", points(for: [.spaceMelee])),
            row("Amps", points(for: [.amp, .operatorAmps])),
            row("K-Drives", points(for: [.kdrive])),
            row("Necramechs", points(for: [.mechSuits]))
        ]

        let other = [
            row("Railjack Components", points(for: [.railjack]))
        ]

        return [weapons, missionsAndIntrinsics, companions, archAndModular, other]
    }

}
