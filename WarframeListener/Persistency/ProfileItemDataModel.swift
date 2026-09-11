//
//  ProfileItem.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import SwiftData

@Model
final class ProfileItemDataModel {
    var equipTime: Double?
    var headshots: Int?
    var hits: Int?
    var assists: Int?
    var kills: Int?
    var xp: Int?
    var type: String
    var fired: Int?
    var profile: ProfileDataModel?
    var masteryItem: MasteryItemDataModel?

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

extension ProfileItemDataModel: ValueTypeConvertible {
    var value: ProfileItemModel {
        .init(
            equipTime: equipTime,
            headshots: headshots,
            hits: hits,
            assists: assists,
            kills: kills,
            xp: xp,
            type: type,
            fired: fired
        )
    }
}

@Model
final class CatalogItemDataModel {
    @Attribute(.unique) var uniqueName: String
    var name: String
    var category: CatalogItemModel.Category
    var maxRank: Int
    var pointsPerRank: Int
    var xpPerRankSq: Int
    var icon: String?
    var obtainable: Bool
    var requiresGilding: Bool
    
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

extension CatalogItemDataModel: ValueTypeConvertible {
    var value: CatalogItemModel {
        .init(
            uniqueName: uniqueName,
            name: name,
            category: category,
            maxRank: maxRank,
            pointsPerRank: pointsPerRank,
            xpPerRankSq: xpPerRankSq,
            icon: icon,
            obtainable: obtainable,
            requiresGilding: requiresGilding
        )
    }
}

@Model
final class MasteryItemDataModel {
    var catalogItem: CatalogItemDataModel
    @Relationship(deleteRule: .cascade, inverse: \ProfileItemDataModel.masteryItem)
    var profileItem: ProfileItemDataModel?
    
    init(profileItemModel: ProfileItemModel?, catalogItemModel: CatalogItemModel) {
        if let profileItemModel {
            profileItem = .init(profileItem: profileItemModel)
        }
        catalogItem = .init(catalogItem: catalogItemModel)
    }
    
    func set(profileItemModel: ProfileItemModel) {
        profileItem = .init(profileItem: profileItemModel)
    }
}

extension MasteryItemDataModel: ValueTypeConvertible {
    var value: MasteryItem {
        return .init(
            profileItemModel: profileItem?.value,
            catalogItemModel: catalogItem.value
        )
    }
}

struct MasteryItem: Equatable, Hashable {
    let profileItemModel: ProfileItemModel?
    let catalogItemModel: CatalogItemModel
}

extension MasteryItem: PersistentModelConvertible {
    var model: MasteryItemDataModel {
        .init(profileItemModel: profileItemModel, catalogItemModel: catalogItemModel)
    }
}
