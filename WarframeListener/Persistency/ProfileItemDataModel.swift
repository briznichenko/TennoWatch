//
//  ProfileItemDataModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import SwiftData

@Model
final class ProfileItemDataModel {
    // MARK: - Object Properties
    var equipTime: Double?
    var headshots: Int?
    var hits: Int?
    var assists: Int?
    var kills: Int?
    var xp: Int?
    @Attribute(.unique) var type: String
    var fired: Int?
    var profile: ProfileDataModel?
    var masteryItem: MasteryItemDataModel?

    // MARK: - Init
    init(profileItem: ProfileItemModel) {
        self.equipTime = profileItem.equipTime
        self.headshots = profileItem.headshots
        self.hits = profileItem.hits
        self.assists = profileItem.assists
        self.kills = profileItem.kills
        self.xp = profileItem.xp
        self.type = profileItem.type
        self.fired = profileItem.fired
    }
}

@Model
final class CatalogItemDataModel {
    // MARK: - Object Properties
    @Attribute(.unique) var uniqueName: String
    var name: String
    var category: CatalogItemModel.Category
    var maxRank: Int
    var pointsPerRank: Int
    var xpPerRankSq: Int
    var icon: String?
    var obtainable: Bool
    var requiresGilding: Bool

    // MARK: - Init
    init(catalogItem: CatalogItemModel) {
        self.uniqueName = catalogItem.uniqueName
        self.name = catalogItem.name
        self.category = catalogItem.category
        self.maxRank = catalogItem.maxRank
        self.pointsPerRank = catalogItem.pointsPerRank
        self.xpPerRankSq = catalogItem.xpPerRankSq
        self.icon = catalogItem.icon
        self.obtainable = catalogItem.obtainable
        self.requiresGilding = catalogItem.requiresGilding
    }
}

@Model
final class MasteryItemDataModel {
    // MARK: - Object Properties
    var catalogItem: CatalogItemDataModel
    // .nullify, not .cascade: this points at the same row ProfileDataModel.items
    // already owns (cascade); cascading here too would delete it out from under the profile.
    @Relationship(deleteRule: .nullify, inverse: \ProfileItemDataModel.masteryItem)
    var profileItem: ProfileItemDataModel?

    // MARK: - Init
    init(profileItemModel: ProfileItemModel?, catalogItemModel: CatalogItemModel) {
        if let profileItemModel {
            profileItem = .init(profileItem: profileItemModel)
        }
        catalogItem = .init(catalogItem: catalogItemModel)
    }
}

extension MasteryItemDataModel {
    var xp: Int { profileItem?.xp ?? 0 }

    var rank: Int {
        let calculatedRank = Int(Double(xp / catalogItem.xpPerRankSq).squareRoot())
        return min(calculatedRank, catalogItem.maxRank)
    }

    var isMastered: Bool { rank >= catalogItem.maxRank }

    var earnedMasteryPoints: Int { rank * catalogItem.pointsPerRank }

    var remainingMasteryPoints: Int { (catalogItem.maxRank - rank) * catalogItem.pointsPerRank }

    var obtainable: Bool { catalogItem.obtainable }

    var masteryState: MasteryState {
        guard catalogItem.obtainable else { return .unobtainable }
        return isMastered ? .mastered : (rank == 0 ? .unmastered : .partiallyMastered)
    }

    var detailText: String {
        switch masteryState {
        case .mastered: Strings.Mastery.itemStateMastered
        case .unobtainable: Strings.Mastery.itemStateUnobtainable
        case .unmastered, .partiallyMastered:
            Strings.Mastery.itemRankProgress(
                rank: rank,
                maxRank: catalogItem.maxRank,
                pointsRemaining: remainingMasteryPoints
            )
        }
    }

    var iconName: String {
        switch masteryState {
        case .mastered: "checkmark.circle.fill"
        case .partiallyMastered: "circle.lefthalf.filled"
        case .unmastered: "circle.dashed"
        case .unobtainable: "lock.fill"
        }
    }

    var isDimmed: Bool {
        switch masteryState {
        case .mastered, .unobtainable: true
        case .unmastered, .partiallyMastered: false
        }
    }
}

enum MasteryState: Equatable {
    case mastered, unmastered, partiallyMastered, unobtainable
}
