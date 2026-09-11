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
    private(set) var catalogs: [CatalogContainer] = []
    private(set) var isLoading: Bool = false

    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository

    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
    }

    var earnedMasteryXP: Int {
        catalogs.flatMap(\.masteryItems).reduce(0) { $0 + $1.earnedMasteryPoints }
    }

    var rankProgress: MasteryRankProgress {
        Self.rankProgress(forXP: earnedMasteryXP)
    }

    var obtainableItemsRemaining: Int {
        catalogs.reduce(0) { $0 + $1.obtainableRemainingCount }
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
            catalogs = try await catalogRepository.getCatalogs()
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
            catalogs = try await catalogRepository.syncCatalogs(with: profile)
        } catch {
            statusText = error.localizedDescription
        }
    }
}
