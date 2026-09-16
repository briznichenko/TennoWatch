//
//  MasteryViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

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

    // MARK: - Init
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchCatalog(forceRefresh: Bool = false) async {
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

    func makeCategoryDetailViewModel(for category: CatalogItemModel.Category) -> MasteryCategoryDetailViewModel {
        .init(category: category, catalogRepository: catalogRepository, errorManager: errorManager)
    }

    func makeSourceDetailViewModel(for categoryName: String) -> MasterySourceCategoryDetailViewModel {
        .init(categoryName: categoryName, catalogRepository: catalogRepository, errorManager: errorManager)
    }
    
    // MARK: - Helper Functions
    private static func rankProgress(forXP xp: Int) -> MasteryRankProgress {
        func cumulativeXP(for rank: Int) -> Int { 2500 * rank * (rank + 1) }
        var completedRanks = 0
        while cumulativeXP(for: completedRanks + 1) <= xp {
            completedRanks += 1
        }
        return MasteryRankProgress(
            rank: completedRanks + 1,
            currentXP: xp,
            xpForCurrentRank: cumulativeXP(for: completedRanks),
            xpForNextRank: cumulativeXP(for: completedRanks + 1)
        )
    }

}
