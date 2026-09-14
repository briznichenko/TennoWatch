//
//  MasteryViewModel.swift
//  WarframeListener
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
    
    private(set) var catalog: MasteryCatalog?
    
    private(set) var isLoading: Bool = false
    
    // MARK: - Computed Properties
    var catalogs: [CatalogContainer] {
        catalog?.items ?? []
    }
    var nonItemSources: [MasteryCategoryModel] {
        catalog?.nonItemSources ?? []
    }
    
    var earnedMasteryXP: Int {
        let itemsMastery = catalogs.flatMap(\.masteryItems).reduce(0) { $0 + $1.earnedMasteryPoints }
        let nonItemsMastery = nonItemSources.map(\.sources).joined().reduce(0) { $0 + $1.mastery }
        return itemsMastery + nonItemsMastery
    }

    var rankProgress: MasteryRankProgress {
        Self.rankProgress(forXP: earnedMasteryXP)
    }

    var obtainableItemsRemaining: Int {
        catalogs.reduce(0) { $0 + $1.obtainableRemainingCount }
    }
    
    // MARK: - Init
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchCatalog() async {
        defer {
            isLoading = false
        }
        
        do {
            if let profile = try? await profileRepository.getProfile() {
                catalog = try await catalogRepository.syncMasteryCatalog(with: profile)
            } else {
                catalog = try await catalogRepository.getMasteryCatalog()
            }
        } catch {
            errorManager.append(error)
        }
    }
    
    // MARK: - Helper Functions
    private static func rankProgress(forXP xp: Int) -> MasteryRankProgress {
        func cumulativeXP(for rank: Int) -> Int { 2500 * rank * (rank + 1) }
        var rank = 0
        while cumulativeXP(for: rank + 1) <= xp {
            rank += 1
        }
        return MasteryRankProgress(
            rank: rank,
            currentXP: xp,
            xpForCurrentRank: cumulativeXP(for: rank),
            xpForNextRank: cumulativeXP(for: rank + 1)
        )
    }

}
