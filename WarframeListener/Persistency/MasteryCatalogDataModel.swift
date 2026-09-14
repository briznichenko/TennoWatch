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

    init(from container: MasteryCatalogContainer) {
        schemaVersion = container.schemaVersion
        gameVersion = container.gameVersion
        generatedAt = container.generatedAt
        totalMasteryMax = container.totalMasteryMax
        obtainableMasteryMax = container.obtainableMasteryMax

        let masteryItems: [MasteryItemDataModel] = container.items.map {
            .init(profileItemModel: .none, catalogItemModel: $0)
        }
        items = DefaultCatalogSyncService.makeCatalogs(from: masteryItems)
        nonItemSources = container.nonItemSources.map { name, sources in
            .init(name: name, sources: sources.map(\.model))
        }
    }
}

extension MasteryCatalogDataModel {
    var earnedMasteryXP: Int {
        let itemsMastery = items.flatMap(\.masteryItems).reduce(0) { $0 + $1.earnedMasteryPoints }
        let nonItemsMastery = nonItemSources.flatMap(\.sources).reduce(0) { $0 + $1.mastery }
        return itemsMastery + nonItemsMastery
    }

    var obtainableItemsRemaining: Int {
        items.reduce(0) { $0 + $1.obtainableRemainingCount }
    }

    var rankProgress: MasteryRankProgress { .rankProgress(forXP: earnedMasteryXP) }
}

struct MasteryRankProgress {
    let rank: Int
    let currentXP: Int
    let xpForCurrentRank: Int
    let xpForNextRank: Int

    // MARK: - Init
    static func rankProgress(forXP xp: Int) -> MasteryRankProgress {
        func cumulativeXP(for rank: Int) -> Int { 2500 * rank * (rank + 1) }
        var rank = 0
        while cumulativeXP(for: rank + 1) <= xp {
            rank += 1
        }
        return MasteryRankProgress(
            rank: rank,
            currentXP: xp,
            xpForCurrentRank: cumulativeXP(for: rank),
            xpForNextRank: cumulativeXP(for: rank + 1)
        )
    }

    var fraction: Double {
        let span = Double(xpForNextRank - xpForCurrentRank)
        guard span > 0 else { return 1 }
        return Double(currentXP - xpForCurrentRank) / span
    }

    var xpToNextRank: Int { xpForNextRank - currentXP }
}

@Model
final class CatalogContainerModel {
    // MARK: - Object Properties
    var category: CatalogItemModel.Category
    var masteryItems: [MasteryItemDataModel]
    var catalog: MasteryCatalogDataModel?

    // MARK: - Init
    init(category: CatalogItemModel.Category, masteryItems: [MasteryItemDataModel]) {
        self.category = category
        self.masteryItems = masteryItems
    }
}

extension CatalogContainerModel {
    var itemsCount: Int { masteryItems.count }
    var masteredItemsCount: Int { masteryItems.filter(\.isMastered).count }

    var obtainableItemsCount: Int { masteryItems.filter(\.obtainable).count }
    var obtainableRemainingCount: Int {
        masteryItems.filter { $0.obtainable && !$0.isMastered }.count
    }

    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
}

@Model
final class MasteryCategoryDataModel {
    // MARK: - Object Properties
    var name: String
    var sources: [MasterySourceDataModel]
    var catalog: MasteryCatalogDataModel?

    // MARK: - Init
    init(name: String, sources: [MasterySourceDataModel]) {
        self.name = name
        self.sources = sources
    }
}

extension MasteryCategoryDataModel {
    var itemsCount: Int { sources.count }
    var masteredItemsCount: Int { sources.filter(\.isMastered).count }
    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
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
}

extension MasterySourceDataModel {
    var masteryState: MasteryState { isMastered ? .mastered : .unmastered }

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
