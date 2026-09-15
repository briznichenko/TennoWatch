//
//  ProfileDataModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

@Model
final class ProfileDataModel: ValueTypeConvertible {
    typealias Value = Profile

    // MARK: - Computed Properties
    var value: Value {
        .init(
            accountID: .init(oid: accountID),
            displayName: displayName,
            playerLevel: playerLevel,
            items: items.map(\.value),
            playerSkills: playerSkills.reduce(into: [String: Int]()) { result, skill in
                result[skill.name] = skill.rank
            },
            missions: missions.map(\.value),
            accountStats: accountStats.value,
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Object Properties
    @Attribute(.unique) var accountID: String
    @Attribute(.unique) var displayName: String
    var playerLevel: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \ProfileItemDataModel.profile)
    var items: [ProfileItemDataModel]
    @Relationship(deleteRule: .cascade, inverse: \IntrinsicsDataModel.profile)
    var playerSkills: [IntrinsicsDataModel]
    @Relationship(deleteRule: .cascade, inverse: \ResultMissionDataModel.profile)
    var missions: [ResultMissionDataModel]
    var accountStats: AccountStatsDataModel
    var lastUpdated: Date

    // MARK: - Init
    init(
        accountID: String,
        displayName: String,
        playerLevel: Int,
        items: [ProfileItemDataModel],
        playerSkills: [IntrinsicsDataModel],
        missions: [ResultMissionDataModel],
        accountStats: AccountStatsDataModel,
        lastUpdated: Date
    ) {
        self.accountID = accountID
        self.displayName = displayName
        self.playerLevel = playerLevel
        self.items = items
        self.playerSkills = playerSkills
        self.missions = missions
        self.accountStats = accountStats
        self.lastUpdated = lastUpdated
    }
}

struct Profile: PersistentModelConvertible {
    typealias Model = ProfileDataModel

    // MARK: - Computed Properties
    var model: Model {
        .init(
            accountID: accountID.oid,
            displayName: displayName,
            playerLevel: playerLevel,
            items: items.map(\.model),
            playerSkills: playerSkills.map { .init(name: $0.key, rank: $0.value) },
            missions: missions.map { .init(completes: $0.completes, tier: $0.tier, tag: $0.tag) },
            accountStats: accountStats.model,
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Object Properties
    let accountID: ID
    let displayName: String
    let playerLevel: Int
    let items: [ProfileItemModel]
    let playerSkills: [String: Int]
    let missions: [ResultMission]
    let accountStats: AccountStats
    let lastUpdated: Date
}

@Model
final class AccountStatsDataModel {
    var deaths: Int
    var reviveCount: Int
    var meleeKills: Int
    var missionsCompleted: Int
    var timePlayedSec: Double
    var healCount: Int
    var income: Int
    var pickupCount: Int
    var fishCount: Int
    var destroyCount: Int
    var ciphersSolved: Int
    var ciphersFailed: Int
    
    init(deaths: Int, reviveCount: Int, meleeKills: Int, missionsCompleted: Int, timePlayedSec: Double, healCount: Int, income: Int, pickupCount: Int, fishCount: Int, destroyCount: Int, ciphersSolved: Int, ciphersFailed: Int) {
        self.deaths = deaths
        self.reviveCount = reviveCount
        self.meleeKills = meleeKills
        self.missionsCompleted = missionsCompleted
        self.timePlayedSec = timePlayedSec
        self.healCount = healCount
        self.income = income
        self.pickupCount = pickupCount
        self.fishCount = fishCount
        self.destroyCount = destroyCount
        self.ciphersSolved = ciphersSolved
        self.ciphersFailed = ciphersFailed
    }
    
    init(stats: AccountStats) {
        self.deaths = stats.deaths
        self.reviveCount = stats.reviveCount
        self.meleeKills = stats.meleeKills
        self.missionsCompleted = stats.missionsCompleted
        self.timePlayedSec = stats.timePlayedSec
        self.healCount = stats.healCount
        self.income = stats.income
        self.pickupCount = stats.pickupCount
        self.fishCount = stats.fishCount
        self.destroyCount = stats.destroyCount
        self.ciphersSolved = stats.ciphersSolved
        self.ciphersFailed = stats.ciphersFailed
    }
}

extension AccountStatsDataModel: ValueTypeConvertible {
    var value: AccountStats {
        .init(
            deaths: deaths,
            reviveCount: reviveCount,
            meleeKills: meleeKills,
            missionsCompleted: missionsCompleted,
            timePlayedSec: timePlayedSec,
            healCount: healCount,
            income: income,
            pickupCount: pickupCount,
            fishCount: fishCount,
            destroyCount: destroyCount,
            ciphersSolved: ciphersSolved,
            ciphersFailed: ciphersFailed
        )
    }
}

struct AccountStats: Codable, Hashable {
    let deaths: Int
    let reviveCount: Int
    let meleeKills: Int
    let missionsCompleted: Int
    let timePlayedSec: Double
    let healCount: Int
    let income: Int
    let pickupCount: Int
    let fishCount: Int
    let destroyCount: Int
    let ciphersSolved: Int
    let ciphersFailed: Int

    static let empty = Self(
        deaths: 0, reviveCount: 0, meleeKills: 0, missionsCompleted: 0,
        timePlayedSec: 0, healCount: 0, income: 0, pickupCount: 0,
        fishCount: 0, destroyCount: 0, ciphersSolved: 0, ciphersFailed: 0
    )
}

extension AccountStats {
    init(stats: Stats) {
        self.init(
            deaths: stats.deaths,
            reviveCount: stats.reviveCount,
            meleeKills: stats.meleeKills,
            missionsCompleted: stats.missionsCompleted,
            timePlayedSec: stats.timePlayedSec,
            healCount: stats.healCount,
            income: stats.income,
            pickupCount: stats.pickupCount,
            fishCount: stats.fishCount,
            destroyCount: stats.destroyCount,
            ciphersSolved: stats.ciphersSolved,
            ciphersFailed: stats.ciphersFailed
        )
    }
}

extension AccountStats: PersistentModelConvertible {
    var model: AccountStatsDataModel {
        .init(stats: self)
    }
}

@Model
final class ResultMissionDataModel {
    // MARK: - Object Properties
    var completes: Int
    var tier: Int?
    @Attribute(.unique) var tag: String
    var profile: ProfileDataModel?

    // MARK: - Init
    init(completes: Int, tier: Int?, tag: String) {
        self.completes = completes
        self.tier = tier
        self.tag = tag
    }

    init(from mission: ResultMission) {
        self.completes = mission.completes
        self.tier = mission.tier
        self.tag = mission.tag
    }
}

extension ResultMissionDataModel: ValueTypeConvertible {
    var value: ResultMission {
        .init(completes: completes, tier: tier, tag: tag)
    }
}

@Model
final class IntrinsicsDataModel {
    // MARK: - Object Properties
    @Attribute(.unique) var name: String
    var rank: Int
    var profile: ProfileDataModel?

    // MARK: - Init
    init(name: String, rank: Int) {
        self.name = name
        self.rank = rank
    }
}

extension IntrinsicsDataModel: ValueTypeConvertible {
    var value: Intrinsics {
        .init(name: name, rank: rank)
    }
}

struct Intrinsics: Codable, Hashable, Equatable {
    let name: String
    let rank: Int
}

extension Intrinsics: PersistentModelConvertible {
    var model: IntrinsicsDataModel {
        .init(name: name, rank: rank)
    }
}

struct ProfileItemModel: Codable, Hashable, Equatable {
    let equipTime: Double?
    let headshots: Int?
    let hits: Int?
    let assists: Int?
    let kills: Int?
    let xp: Int?
    let type: String
    let fired: Int?
    
    static let stub = Self.init(equipTime: 10, headshots: 2, hits: 5, assists: 3, kills: 2, xp: 1000, type: "type", fired: 100)
}

extension ProfileItemModel: PersistentModelConvertible {
    var model: ProfileItemDataModel {
        .init(profileItem: self)
    }
}
