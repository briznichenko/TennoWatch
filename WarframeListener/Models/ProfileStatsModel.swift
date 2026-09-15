//
//  ProfileStatsModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Foundation

struct IntrinsicItem: Identifiable, Hashable {
    // MARK: - Object Properties
    let key: String
    let name: String
    let rank: Int
    let maxRank: Int

    // MARK: - Computed Properties
    var id: String { key }
    var fraction: Double { maxRank > 0 ? Double(rank) / Double(maxRank) : 0 }
}

struct IntrinsicGroup: Identifiable, Hashable {
    // MARK: - Object Properties
    let name: String
    let intrinsics: [IntrinsicItem]

    // MARK: - Computed Properties
    var id: String { name }
}

struct ProfileItemStat: Identifiable, Hashable {
    // MARK: - Object Properties
    let type: String
    let name: String
    let kills: Int
    let headshots: Int
    let assists: Int
    let xp: Int

    // MARK: - Computed Properties
    var id: String { type }
}

struct MissionStat: Identifiable, Hashable {
    // MARK: - Object Properties
    let tag: String
    let name: String
    let tier: Int?
    let completes: Int

    // MARK: - Computed Properties
    var id: String { tag }
}

struct AccountStatRow: Identifiable, Hashable {
    // MARK: - Object Properties
    let label: String
    let value: String

    // MARK: - Computed Properties
    var id: String { label }
}

extension Profile {
    // MARK: - Object Properties
    private static let intrinsicMaxRank = 10
    private static let drifterKeyPrefix = "LPS_DRIFT_"
    private static let railjackKeyPrefix = "LPS_"

    // MARK: - Computed Properties
    var intrinsicGroups: [IntrinsicGroup] {
        var railjack: [IntrinsicItem] = []
        var drifter: [IntrinsicItem] = []

        for (key, rank) in playerSkills {
            if key.hasPrefix(Self.drifterKeyPrefix) {
                let name = String(key.dropFirst(Self.drifterKeyPrefix.count)).replacingOccurrences(of: "_", with: " ").capitalized
                drifter.append(.init(key: key, name: name, rank: rank, maxRank: Self.intrinsicMaxRank))
            } else if key.hasPrefix(Self.railjackKeyPrefix) {
                let name = String(key.dropFirst(Self.railjackKeyPrefix.count)).replacingOccurrences(of: "_", with: " ").capitalized
                railjack.append(.init(key: key, name: name, rank: rank, maxRank: Self.intrinsicMaxRank))
            }
        }

        var groups: [IntrinsicGroup] = []
        if !railjack.isEmpty {
            groups.append(.init(name: Strings.Profile.railjackIntrinsics, intrinsics: railjack.sorted { $0.name < $1.name }))
        }
        if !drifter.isEmpty {
            groups.append(.init(name: Strings.Profile.drifterIntrinsics, intrinsics: drifter.sorted { $0.name < $1.name }))
        }
        return groups
    }

    var itemStats: [ProfileItemStat] {
        items.map {
            .init(
                type: $0.type,
                name: $0.type.spacedByCamelCase,
                kills: $0.kills ?? 0,
                headshots: $0.headshots ?? 0,
                assists: $0.assists ?? 0,
                xp: $0.xp ?? 0
            )
        }
    }

    var missionStats: [MissionStat] {
        missions.map {
            .init(tag: $0.tag, name: $0.tag.spacedByCamelCase, tier: $0.tier, completes: $0.completes)
        }
    }

    var accountStatRows: [AccountStatRow] {
        [
            .init(label: Strings.Profile.statMeleeKills, value: accountStats.meleeKills.formatted()),
            .init(label: Strings.Profile.statDeaths, value: accountStats.deaths.formatted()),
            .init(label: Strings.Profile.statRevives, value: accountStats.reviveCount.formatted()),
            .init(label: Strings.Profile.statMissionsCompleted, value: accountStats.missionsCompleted.formatted()),
            .init(label: Strings.Profile.statTimePlayed, value: Self.timePlayedFormatter.string(from: accountStats.timePlayedSec) ?? "—"),
            .init(label: Strings.Profile.statIncome, value: accountStats.income.formatted()),
            .init(label: Strings.Profile.statHealCount, value: accountStats.healCount.formatted()),
            .init(label: Strings.Profile.statPickupCount, value: accountStats.pickupCount.formatted()),
            .init(label: Strings.Profile.statFishCaught, value: accountStats.fishCount.formatted()),
            .init(label: Strings.Profile.statDestroyed, value: accountStats.destroyCount.formatted()),
            .init(label: Strings.Profile.statCiphersSolved, value: accountStats.ciphersSolved.formatted()),
            .init(label: Strings.Profile.statCiphersFailed, value: accountStats.ciphersFailed.formatted())
        ]
    }

    // MARK: - Helper Properties
    private static let timePlayedFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter
    }()
}
