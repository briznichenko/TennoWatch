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
    let remainingPoints: Int
    var lockedRemainingPoints: Int = 0

    var id: String { name }
}

@Observable
@MainActor
final class MasteryViewModel {
    // MARK: - Object Properties
    private let profileRepository: ProfileRepository
    private let catalogRepository: CatalogRepository
    let errorManager: ErrorManager
    
    private(set) var summary: MasteryCatalogSummary?
    private(set) var playerRank: Int?
    private var allBreakdownSections: [[MasteryBreakdownRow]] = []

    var excludeLockedItems = false

    private(set) var isLoading: Bool = false

    // MARK: - Computed Properties
    var categories: [CatalogContainerSummary] {
        let categories = summary?.categories ?? []
        return excludeLockedItems ? categories.map { $0.excludingLockedItems() } : categories
    }

    var breakdownSections: [[MasteryBreakdownRow]] {
        guard excludeLockedItems else { return allBreakdownSections }
        return allBreakdownSections.map { rows in
            rows.map { row in
                .init(
                    name: row.name,
                    earnedPoints: row.earnedPoints,
                    remainingPoints: row.remainingPoints - row.lockedRemainingPoints
                )
            }
        }
    }
    var nonItemCategories: [MasteryCategorySummary] {
        summary?.nonItemCategories ?? []
    }

    var earnedMasteryXP: Int {
        categories.reduce(0) { $0 + $1.earnedMasteryPoints }
            + nonItemCategories.reduce(0) { $0 + $1.earnedMasteryPoints }
    }

    var rankProgress: MasteryRankProgress {
        MasteryRankProgress.calculate(forXP: earnedMasteryXP, playerRank: playerRank)
    }

    var obtainableMasteryXP: Int {
        guard let summary else { return 0 }
        return summary.categories.reduce(0) { $0 + $1.earnedMasteryPoints - $1.lockedEarnedMasteryPoints }
            + summary.nonItemCategories.reduce(0) { $0 + $1.earnedMasteryPoints }
    }

    var obtainableMasteryMax: Int { summary?.obtainableMasteryMax ?? 0 }

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
            let profile: Profile?
            do {
                profile = try await profileRepository.getProfile(forceRefresh: forceRefresh)
            } catch PersistentProfileRepository.ProfileError.noPlayerId {
                profile = nil
            }
            let updatedSummary = try await catalogRepository.getMasterySummary()
            guard !Task.isCancelled else { return }
            summary = updatedSummary
            playerRank = profile?.isLocal == true ? nil : profile?.playerLevel
        } catch {
            if !Task.isCancelled && !(error is CancellationError) {
                errorManager.append(error)
            }
        }
    }

    func loadBreakdown() async {
        do {
            let catalog = try await catalogRepository.getMasteryCatalog()
            guard !Task.isCancelled else { return }
            let sources = catalog.nonItemSources
            guard let nodes = sources.first(where: { $0.name == MasterySourceType.nodes.rawValue }),
                  let intrinsics = sources.first(where: { $0.name == MasterySourceType.intrinsics.rawValue }),
                  let junctions = sources.first(where: { $0.name == MasterySourceType.junctions.rawValue }) else {
                throw PersistentCatalogRepository.CatalogError.wrongCategory
            }
            allBreakdownSections = Self.makeBreakdownSections(
                categories: catalog.items,
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
    private static func makeBreakdownSections(
        categories: [CatalogContainer],
        nodes: MasteryCategoryModel,
        intrinsics: MasteryCategoryModel,
        junctions: MasteryCategoryModel
    ) -> [[MasteryBreakdownRow]] {
        func row(_ name: String, for members: Set<CatalogItemModel.Category>) -> MasteryBreakdownRow {
            let items = categories
                .filter { members.contains($0.category) }
                .flatMap(\.masteryItems)
            return .init(
                name: name,
                earnedPoints: items.reduce(0) { $0 + $1.earnedMasteryPoints },
                remainingPoints: items.reduce(0) { $0 + $1.remainingMasteryPoints },
                lockedRemainingPoints: items.filter { !$0.obtainable }.reduce(0) { $0 + $1.remainingMasteryPoints }
            )
        }
        func row(
            _ name: String,
            in sources: [MasterySourceModel],
            where predicate: (MasterySourceModel) -> Bool
        ) -> MasteryBreakdownRow {
            let matchingSources = sources.filter(predicate)
            return .init(
                name: name,
                earnedPoints: matchingSources.filter { $0.isMastered == true }.reduce(0) { $0 + $1.mastery },
                remainingPoints: matchingSources.filter { $0.isMastered != true }.reduce(0) { $0 + $1.mastery }
            )
        }

        let weapons = [
            row(Strings.Mastery.Breakdown.warframes, for: [.suits]),
            row(Strings.Mastery.Breakdown.primaryWeapons, for: [.longGuns]),
            row(Strings.Mastery.Breakdown.secondaryWeapons, for: [.pistols]),
            row(Strings.Mastery.Breakdown.meleeWeapons, for: [.melee, .zaw]),
            row(Strings.Mastery.Breakdown.kitguns, for: [.kitgun])
        ]

        let missionsAndIntrinsics = [
            row(Strings.Mastery.Breakdown.missions, in: nodes.sources + junctions.sources) { !$0.name.contains("Steel Path") },
            row(Strings.Mastery.Breakdown.steelPathMissions, in: nodes.sources + junctions.sources) { $0.name.contains("Steel Path") },
            row(Strings.Profile.railjackIntrinsics, in: intrinsics.sources) { $0.name.contains("Railjack") },
            row(Strings.Profile.drifterIntrinsics, in: intrinsics.sources) { $0.name.contains("Drifter") }
        ]

        let companions = [
            row(Strings.Mastery.Breakdown.sentinels, for: [.sentinels]),
            row(Strings.Mastery.Breakdown.sentinelWeapons, for: [.sentinelWeapons]),
            row(Strings.Mastery.Breakdown.companions, for: [.kubrowPets, .moa, .hound, .specialItems])
        ]

        let archAndModular = [
            row(Strings.Mastery.Breakdown.archwing, for: [.spaceSuits]),
            row(Strings.Mastery.Breakdown.archgun, for: [.spaceGuns]),
            row(Strings.Mastery.Breakdown.archmelee, for: [.spaceMelee]),
            row(Strings.Mastery.Breakdown.amps, for: [.amp, .operatorAmps]),
            row(Strings.Mastery.Breakdown.kDrives, for: [.kdrive]),
            row(Strings.Mastery.Breakdown.necramechs, for: [.mechSuits])
        ]

        let other = [
            row(Strings.Mastery.Breakdown.railjackComponents, for: [.railjack])
        ]

        return [weapons, missionsAndIntrinsics, companions, archAndModular, other]
    }
}
