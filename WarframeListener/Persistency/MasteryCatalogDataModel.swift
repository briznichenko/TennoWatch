//
//  MasteryCatalog.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

@Model
final class MasteryCatalogDataModel{
    var schemaVersion: Double
    var gameVersion: String
    var generatedAt: Date
    var totalMasteryMax: Int
    var obtainableMasteryMax: Int
    var items: [MasteryItemDataModel]
    
    init(schemaVersion: Double, gameVersion: String, generatedAt: Date, totalMasteryMax: Int, obtainableMasteryMax: Int, items: [MasteryItemDataModel]) {
        self.schemaVersion = schemaVersion
        self.gameVersion = gameVersion
        self.generatedAt = generatedAt
        self.totalMasteryMax = totalMasteryMax
        self.obtainableMasteryMax = obtainableMasteryMax
        self.items = items
    }
    
    init(from model: MasteryCatalogContainer) {
        schemaVersion = model.schemaVersion
        gameVersion = model.gameVersion
        generatedAt = model.generatedAt
        totalMasteryMax = model.totalMasteryMax
        obtainableMasteryMax = model.obtainableMasteryMax
        items = model.items.map { .init(profileItemModel: .none, catalogItemModel: $0) }
    }
}

extension MasteryCatalogDataModel: ValueTypeConvertible {
    var value: MasteryCatalog {
        .init(
            schemaVersion: schemaVersion,
            gameVersion: gameVersion,
            generatedAt: generatedAt,
            totalMasteryMax: totalMasteryMax,
            obtainableMasteryMax: obtainableMasteryMax,
            items: items.map(\.value)
        )
    }
}

struct MasteryCatalog {
    let schemaVersion: Double
    let gameVersion: String
    let generatedAt: Date
    let totalMasteryMax: Int
    let obtainableMasteryMax: Int
    let items: [MasteryItem]
}
