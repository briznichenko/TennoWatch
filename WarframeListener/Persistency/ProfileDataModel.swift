//
//  ProfileDataModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

@Model
final class ProfileDataModel {
    // MARK: - Object Properties
    @Attribute(.unique) var accountID: String
    @Attribute(.unique) var displayName: String
    @Relationship(deleteRule: .cascade, inverse: \ProfileItemDataModel.profile)
    var items: [ProfileItemDataModel]
    var playerSkills: [IntrinsicsDataModel]
    var missions: [ResultMissionDataModel]
    var lastUpdated: Date

    // MARK: - Init
    init(
        accountID: ID,
        displayName: String,
        items: [ProfileItemModel],
        playerSkills: [String: Int],
        missions: [ResultMission],
        lastUpdated: Date
    ) {
        self.accountID = accountID.oid
        self.displayName = displayName
        self.items = items.map(\.model)
        self.playerSkills = playerSkills.map { .init(name: $0.key, rank: $0.value) }
        self.missions = missions.map { .init(from: $0) }
        self.lastUpdated = lastUpdated
    }
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
