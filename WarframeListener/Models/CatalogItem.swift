//
//  CatalogItem.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

struct CatalogContainer: Decodable {
    let schemaVersion: Int
    let gameVersion: String
    let generatedAt: Date
    let totalMasteryMax: Int
    let obtainableMasteryMax: Int
    let items: [CatalogItem]
}

struct Catalog: Identifiable {
    let id = UUID()
    let category: CatalogItem.Category
    let items: [CatalogItem]
}

struct CatalogItem: Decodable, Hashable, Identifiable {
    enum Category: String, CaseIterable, Decodable {
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
