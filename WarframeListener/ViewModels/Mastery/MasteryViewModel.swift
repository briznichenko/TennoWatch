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
    private(set) var statusText: String = ""
    private(set) var catalog: MasteryCatalog?
    var catalogs: [CatalogContainer] {
        catalog?.catalogs ?? []
    }
    var nonItemSources: [MasteryCategoryModel] {
        catalog?.nonItemSources ?? []
    }
    private(set) var isLoading: Bool = false

    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository

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
    
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
    }

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

    func fetchCatalog() async {
        do {
            catalog = try await catalogRepository.getMasteryCatalog()
        } catch {
            statusText = error.localizedDescription
        }
    }
    
    func fetchProfile() async {
        defer {
            isLoading = false
        }
        
        isLoading = true
        statusText = "Loading..."

        do {
            let profile = try await profileRepository.getProfile(withPlayerId: .none)
            catalog = try await catalogRepository.syncMasteryCatalog(with: profile)
        } catch {
            statusText = error.localizedDescription
        }
    }
}
