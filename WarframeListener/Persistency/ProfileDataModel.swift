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
            items: items.map(\.value),
            playerSkills: playerSkills.reduce(into: [String: Int]()) { result, skill in
                result[skill.name] = skill.rank
            },
            missions: missions.map(\.value),
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Object Properties
    @Attribute(.unique) var accountID: String
    @Attribute(.unique) var displayName: String
    @Relationship(deleteRule: .cascade, inverse: \ProfileItemDataModel.profile)
    var items: [ProfileItemDataModel]
    var playerSkills: [IntrinsicsDataModel]
    var missions: [ResultMissionDataModel]
    var lastUpdated: Date

    // MARK: - Init
    init(accountID: String, displayName: String, items: [ProfileItemDataModel], playerSkills: [IntrinsicsDataModel], missions: [ResultMissionDataModel], lastUpdated: Date) {
        self.accountID = accountID
        self.displayName = displayName
        self.items = items
        self.playerSkills = playerSkills
        self.missions = missions
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
            items: items.map(\.model),
            playerSkills: playerSkills.map { .init(name: $0.key, rank: $0.value) },
            missions: missions.map { .init(completes: $0.completes, tier: $0.tier, tag: $0.tag) },
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Object Properties
    let accountID: ID
    let displayName: String
    let items: [ProfileItemModel]
    let playerSkills: [String: Int]
    let missions: [ResultMission]
    let lastUpdated: Date
}

@Model
final class ResultMissionDataModel {
    // MARK: - Object Properties
    var completes: Int
    var tier: Int?
    @Attribute(.unique) var tag: String

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
