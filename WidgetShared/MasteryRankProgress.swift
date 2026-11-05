//
//  MasteryRankProgress.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/03/26.
//

import Foundation

struct MasteryRankProgress: Sendable {
    let rank: Int
    let currentXP: Int
    let xpForCurrentRank: Int
    let xpForNextRank: Int

    var fraction: Double {
        let span = Double(xpForNextRank - xpForCurrentRank)
        guard span > 0 else { return 1 }
        return min(1, max(0, Double(currentXP - xpForCurrentRank) / span))
    }

    var xpToNextRank: Int { max(0, xpForNextRank - currentXP) }

    static func calculate(forXP xp: Int, playerRank: Int?) -> MasteryRankProgress {
        let legendaryCapXP = RankRequirements.rankXPMultiplier * RankRequirements.legendaryCapRank * RankRequirements.legendaryCapRank
        func cumulativeXP(for rank: Int) -> Int {
            guard rank > RankRequirements.legendaryCapRank else { return RankRequirements.rankXPMultiplier * rank * rank }
            return legendaryCapXP + (rank - RankRequirements.legendaryCapRank) * RankRequirements.legendaryRankXP
        }
        var completedRanks = 0
        while cumulativeXP(for: completedRanks + 1) <= xp {
            completedRanks += 1
        }
        let rank = playerRank.map { max(0, $0) } ?? completedRanks
        let currentXP = cumulativeXP(for: rank)
        return MasteryRankProgress(
            rank: rank,
            currentXP: xp,
            xpForCurrentRank: currentXP,
            xpForNextRank: cumulativeXP(for: rank + 1)
        )
    }
}

private struct RankRequirements {
    static let legendaryCapRank = 30
    static let rankXPMultiplier = 2500
    static let legendaryRankXP = 147_500
}
