//
//  MasteryCatalogDataModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

@Model
final class MasteryCatalogDataModel {
    @Attribute(.unique) var schemaVersion: Double
    var gameVersion: String
    var generatedAt: Date
    var totalMasteryMax: Int
    var obtainableMasteryMax: Int
    @Relationship(inverse: \CatalogContainerModel.catalog)
    var items: [CatalogContainerModel]
    @Relationship(inverse: \MasteryCategoryDataModel.catalog)
    var nonItemSources: [MasteryCategoryDataModel]
    
    init(schemaVersion: Double, gameVersion: String, generatedAt: Date, totalMasteryMax: Int, obtainableMasteryMax: Int, items: [CatalogContainerModel], nonItemSources: [MasteryCategoryDataModel]) {
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
        let masteryItems: [MasteryItem] = model.items.map {
            .init(profileItemModel: .none,
                  catalogItemModel: $0)
        }

        items = DefaultCatalogSyncService.makeCatalogs(from: masteryItems).map(\.model)
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
final class CatalogContainerModel {
    var category: CatalogItemModel.Category
    var masteryItems: [MasteryItemDataModel]
    var catalog: MasteryCatalogDataModel?
    
    init(category: CatalogItemModel.Category, masteryItems: [MasteryItemDataModel]) {
        self.category = category
        self.masteryItems = masteryItems
    }
}

extension CatalogContainerModel: ValueTypeConvertible {
    var value: CatalogContainer {
        .init(category: category, masteryItems: masteryItems.map(\.value))
    }
}

@Model
final class MasteryCategoryDataModel {
    var name: String
    var sources: [MasterySourceDataModel]
    var catalog: MasteryCatalogDataModel?
    
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
    @Attribute(.unique) var uniqueName: String
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
    var items: [CatalogContainer]
    var nonItemSources: [MasteryCategoryModel]
}

extension MasteryCatalog {
    init(container: MasteryCatalogContainer) {
        self.schemaVersion = container.schemaVersion
        self.gameVersion = container.gameVersion
        self.generatedAt = container.generatedAt
        self.totalMasteryMax = container.totalMasteryMax
        self.obtainableMasteryMax = container.obtainableMasteryMax
        let masteryItems: [MasteryItem] = container.items.map {
            .init(profileItemModel: .none,
                  catalogItemModel: $0)
        }

        items = DefaultCatalogSyncService.makeCatalogs(from: masteryItems)
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
