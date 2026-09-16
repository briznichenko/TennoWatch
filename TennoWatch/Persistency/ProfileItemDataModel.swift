//
//  ProfileItemDataModel.swift
//  TennoWatch
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
    // MARK: - Object Properties
    var catalogItem: CatalogItemDataModel
    @Relationship(deleteRule: .cascade, inverse: \ProfileItemDataModel.masteryItem)
    var profileItem: ProfileItemDataModel?
    var isMastered: Bool = false

    // MARK: - Init
    init(profileItemModel: ProfileItemModel?, catalogItemModel: CatalogItemModel) {
        if let profileItemModel {
            profileItem = .init(profileItem: profileItemModel)
        }
        catalogItem = .init(catalogItem: catalogItemModel)
        isMastered = MasteryItem(profileItemModel: profileItemModel, catalogItemModel: catalogItemModel).isMastered
    }

    // MARK: - Functions
    func set(profileItemModel: ProfileItemModel) {
        profileItem = .init(profileItem: profileItemModel)
        isMastered = MasteryItem(profileItemModel: profileItemModel, catalogItemModel: catalogItem.value).isMastered
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
    // MARK: - Object Properties
    let profileItemModel: ProfileItemModel?
    let catalogItemModel: CatalogItemModel

    // MARK: - Computed Properties
    var xp: Int { profileItemModel?.xp ?? 0 }

    var rank: Int {
        let calculatedRank = Int(Double(xp / catalogItemModel.xpPerRankSq).squareRoot())
        return min(calculatedRank, catalogItemModel.maxRank)
    }

    var isMastered: Bool { rank >= catalogItemModel.maxRank }

    var earnedMasteryPoints: Int { rank * catalogItemModel.pointsPerRank }

    var remainingMasteryPoints: Int { (catalogItemModel.maxRank - rank) * catalogItemModel.pointsPerRank }
    
    var obtainable: Bool { catalogItemModel.obtainable }

    enum MasteryState: Equatable {
        case mastered, unmastered, partiallyMastered, unobtainable
    }

    var masteryState: MasteryState {
        guard catalogItemModel.obtainable else { return .unobtainable }
        return isMastered ? .mastered : (rank == 0 ? .unmastered : .partiallyMastered)
    }
}

extension MasteryItem: PersistentModelConvertible {
    var model: MasteryItemDataModel {
        .init(profileItemModel: profileItemModel, catalogItemModel: catalogItemModel)
    }
}
