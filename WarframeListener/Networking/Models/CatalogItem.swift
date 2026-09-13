//
//  CatalogItemModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

typealias NetworkModel = Decodable

struct MasteryCatalogContainer: NetworkModel {
    let schemaVersion: Double
    let gameVersion: String
    let generatedAt: Date
    let totalMasteryMax: Int
    let obtainableMasteryMax: Int
    let items: [CatalogItemModel]
    let nonItemSources: [String: [MasterySourceModel]]
}

struct MasterySourceModel: NetworkModel, Hashable {
    let uniqueName: String
    let name: String
    let mastery: Int
    @Omitted var isMastered: Bool?
}

extension MasterySourceModel: PersistentModelConvertible {
    var model: MasterySourceDataModel {
        .init(
            uniqueName: uniqueName,
            name: name,
            mastery: mastery,
            isMastered: isMastered ?? false
        )
    }
}

struct CatalogItemModel: Codable, Hashable, Identifiable, Equatable {
    enum Category: String, CaseIterable, Codable {
        case suits = "Suits"
        case spaceSuits = "SpaceSuits"
        case mechSuits = "MechSuits"
        case sentinels = "Sentinels"
        case kubrowPets = "KubrowPets"
        case specialItems = "SpecialItems"
        case longGuns = "LongGuns"
        case pistols = "Pistols"
        case melee = "Melee"
        case spaceGuns = "SpaceGuns"
        case spaceMelee = "SpaceMelee"
        case sentinelWeapons = "SentinelWeapons"
        case operatorAmps = "OperatorAmps"
        case zaw = "ZAW"
        case kitgun = "KITGUN"
        case amp = "AMP"
        case moa = "MOA"
        case hound = "HOUND"
        case kdrive = "KDRIVE"
        case railjack = "RAILJACK"
        
        var displayName: String {
            switch self {
            case .suits:
                "warframe"
            case .spaceSuits:
                "archwing"
            case .mechSuits:
                "necramech"
            case .sentinels:
                "sentinel"
            case .kubrowPets:
                "kubrow"
            case .specialItems:
                "special"
            case .longGuns:
                "primary"
            case .pistols:
                "secondary"
            case .melee:
                "melee"
            case .spaceGuns:
                "archgun"
            case .spaceMelee:
                "archgun melee"
            case .sentinelWeapons:
                "sentinel weapons"
            case .operatorAmps:
                "amps"
            case .zaw:
                "zaws"
            case .kitgun:
                "kitguns"
            case .amp:
                "amp"
            case .moa:
                "moa"
            case .hound:
                "hound"
            case .kdrive:
                "k-drive"
            case .railjack:
                "railjack"
            }
        }
    }
    
    var id: String {
        uniqueName
    }
    
    let uniqueName: String
    let name: String
    let category: Category
    let maxRank: Int
    let pointsPerRank: Int
    let xpPerRankSq: Int
    let icon: String?
    let obtainable: Bool
    let requiresGilding: Bool
}
