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
    // MARK: - Object Properties
    @Attribute(.unique) var schemaVersion: Double
    var gameVersion: String
    var generatedAt: Date
    var totalMasteryMax: Int
    var obtainableMasteryMax: Int
    @Relationship(inverse: \CatalogContainerModel.catalog)
    var items: [CatalogContainerModel]
    @Relationship(inverse: \MasteryCategoryDataModel.catalog)
    var nonItemSources: [MasteryCategoryDataModel]

    // MARK: - Init
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

    var summary: MasteryCatalogSummary {
        .init(
            totalMasteryMax: totalMasteryMax,
            obtainableMasteryMax: obtainableMasteryMax,
            categories: items.map(\.summary),
            nonItemCategories: nonItemSources.map(\.summary)
        )
    }
}

@Model
final class CatalogContainerModel {
    // MARK: - Object Properties
    var category: CatalogItemModel.Category
    var masteryItems: [MasteryItemDataModel]
    var catalog: MasteryCatalogDataModel?

    var itemsCount: Int = 0
    var obtainableItemsCount: Int = 0
    var masteredItemsCount: Int = 0
    var masteredObtainableCount: Int = 0
    var fullyMasteredPoints: Int = 0
    var partialPoints: Int = 0

    // MARK: - Init
    init(category: CatalogItemModel.Category, masteryItems: [MasteryItemDataModel]) {
        self.category = category
        self.masteryItems = masteryItems
        self.itemsCount = masteryItems.count
        self.obtainableItemsCount = masteryItems.filter { $0.catalogItem.obtainable }.count
        self.masteredItemsCount = masteryItems.filter(\.isMastered).count
        self.masteredObtainableCount = masteryItems.filter { $0.isMastered && $0.catalogItem.obtainable }.count
        self.fullyMasteredPoints = masteryItems
            .filter(\.isMastered)
            .reduce(0) { $0 + $1.catalogItem.maxRank * $1.catalogItem.pointsPerRank }
        self.partialPoints = 0
    }
}

extension CatalogContainerModel: ValueTypeConvertible {
    var value: CatalogContainer {
        .init(category: category, masteryItems: masteryItems.map(\.value))
    }

    var summary: CatalogContainerSummary {
        .init(
            category: category,
            itemsCount: itemsCount,
            masteredItemsCount: masteredItemsCount,
            obtainableItemsCount: obtainableItemsCount,
            obtainableRemainingCount: obtainableItemsCount - masteredObtainableCount,
            earnedMasteryPoints: fullyMasteredPoints + partialPoints
        )
    }
}

@Model
final class MasteryCategoryDataModel {
    // MARK: - Object Properties
    var name: String
    var sources: [MasterySourceDataModel]
    var catalog: MasteryCatalogDataModel?

    var itemsCount: Int = 0
    var masteredItemsCount: Int = 0
    var masteredPoints: Int = 0

    // MARK: - Init
    init(name: String, sources: [MasterySourceDataModel]) {
        self.name = name
        self.sources = sources
        self.itemsCount = sources.count
        self.masteredItemsCount = sources.filter(\.isMastered).count
        self.masteredPoints = sources.filter(\.isMastered).reduce(0) { $0 + $1.mastery }
    }
}

extension MasteryCategoryDataModel: ValueTypeConvertible {
    var value: MasteryCategoryModel {
        .init(name: name, sources: sources.map(\.value))
    }

    var summary: MasteryCategorySummary {
        .init(
            name: name,
            itemsCount: itemsCount,
            masteredItemsCount: masteredItemsCount,
            earnedMasteryPoints: masteredPoints
        )
    }
}

@Model
final class MasterySourceDataModel {
    // MARK: - Object Properties
    @Attribute(.unique) var uniqueName: String
    var name: String
    var mastery: Int
    var isMastered: Bool

    // MARK: - Init
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
    // MARK: - Object Properties
    let schemaVersion: Double
    let gameVersion: String
    let generatedAt: Date
    let totalMasteryMax: Int
    let obtainableMasteryMax: Int
    var items: [CatalogContainer]
    var nonItemSources: [MasteryCategoryModel]
}

extension MasteryCatalog {
    // MARK: - Init
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

struct MasteryCatalogSummary {
    // MARK: - Object Properties
    let totalMasteryMax: Int
    let obtainableMasteryMax: Int
    let categories: [CatalogContainerSummary]
    let nonItemCategories: [MasteryCategorySummary]
}

struct CatalogContainerSummary: Identifiable, Hashable {
    // MARK: - Object Properties
    let category: CatalogItemModel.Category
    let itemsCount: Int
    let masteredItemsCount: Int
    let obtainableItemsCount: Int
    let obtainableRemainingCount: Int
    let earnedMasteryPoints: Int

    // MARK: - Computed Properties
    var id: CatalogItemModel.Category { category }
    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
}

struct MasteryCategorySummary: Identifiable, Hashable {
    // MARK: - Object Properties
    let name: String
    let itemsCount: Int
    let masteredItemsCount: Int
    let earnedMasteryPoints: Int

    // MARK: - Computed Properties
    var id: String { name }
    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
}
