//
//  MasteryCatalog.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

@Model
final class MasteryCatalogDataModel {
    var schemaVersion: Double
    var gameVersion: String
    var generatedAt: Date
    var totalMasteryMax: Int
    var obtainableMasteryMax: Int
    var items: [MasteryItemDataModel]
    var nonItemSources: [MasteryCategoryDataModel]
    
    init(schemaVersion: Double, gameVersion: String, generatedAt: Date, totalMasteryMax: Int, obtainableMasteryMax: Int, items: [MasteryItemDataModel], nonItemSources: [MasteryCategoryDataModel]) {
        self.schemaVersion = schemaVersion
        self.gameVersion = gameVersion
        self.generatedAt = generatedAt
        self.totalMasteryMax = totalMasteryMax
        self.obtainableMasteryMax = obtainableMasteryMax
        self.items = items
        self.nonItemSources = nonItemSources
    }
    
    init(from model: MasteryCatalogContainer) {
        schemaVersion = model.schemaVersion
        gameVersion = model.gameVersion
        generatedAt = model.generatedAt
        totalMasteryMax = model.totalMasteryMax
        obtainableMasteryMax = model.obtainableMasteryMax
        items = model.items.map {
            .init(profileItemModel: .none,
                  catalogItemModel: $0)
        }
        nonItemSources = model.nonItemSources.map {
            .init(name: $0, sources: $1.map(\.model))
        }
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
            items: items.map(\.value),
            nonItemSources: nonItemSources.map(\.value)
        )
    }
}

@Model
final class MasteryCategoryDataModel {
    var name: String
    var sources: [MasterySourceDataModel]
    
    init(name: String, sources: [MasterySourceDataModel]) {
        self.name = name
        self.sources = sources
    }
}

extension MasteryCategoryDataModel: ValueTypeConvertible {
    var value: MasteryCategoryModel {
        .init(name: name, sources: sources.map(\.value))
    }
}

@Model
final class MasterySourceDataModel {
    var uniqueName: String
    var name: String
    var mastery: Int
    var isMastered: Bool
    
    init(uniqueName: String, name: String, mastery: Int, isMastered: Bool) {
        self.uniqueName = uniqueName
        self.name = name
        self.mastery = mastery
        self.isMastered = isMastered
    }
    
    init (from model: MasterySourceModel) {
        self.uniqueName = model.uniqueName
        self.name = model.name
        self.mastery = model.mastery
        self.isMastered = false
    }
}

extension MasterySourceDataModel: ValueTypeConvertible {
    var value: MasterySourceModel {
        .init(
            uniqueName: uniqueName,
            name: name,
            mastery: mastery,
            isMastered: isMastered
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
    let nonItemSources: [MasteryCategoryModel]
    
    // TODO: - get rid of 
    var catalogs: [CatalogContainer] = []
}

extension MasteryCatalog {
    init(container: MasteryCatalogContainer) {
        self.schemaVersion = container.schemaVersion
        self.gameVersion = container.gameVersion
        self.generatedAt = container.generatedAt
        self.totalMasteryMax = container.totalMasteryMax
        self.obtainableMasteryMax = container.obtainableMasteryMax
        items = container.items.map {
            .init(profileItemModel: .none,
                  catalogItemModel: $0)
        }
        nonItemSources = container.nonItemSources.map {
            .init(name: $0, sources: $1)
        }
    }
}

extension MasteryCatalog: PersistentModelConvertible {
    var model: MasteryCatalogDataModel {
        .init(
            schemaVersion: schemaVersion,
            gameVersion: gameVersion,
            generatedAt: generatedAt,
            totalMasteryMax: totalMasteryMax,
            obtainableMasteryMax: obtainableMasteryMax,
            items: items.map(\.model),
            nonItemSources: nonItemSources.map(\.model)
        )
    }
}

struct MasteryCategory {
    let name: String
    let sources: [MasterySourceModel]
}

extension MasteryCategory: PersistentModelConvertible {
    var model: MasteryCategoryDataModel {
        .init(name: name, sources: sources.map(\.model))
    }
}
