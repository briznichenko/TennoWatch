//
//  CatalogSyncService.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

protocol CatalogSyncService {
    func syncCatalogs(with profileModel: Profile, against catalog: MasteryCatalog) -> [CatalogContainer]
    func syncNonItemSources(with profileModel: Profile, against catalog: MasteryCatalog) -> [MasteryCategoryModel]
}

struct DefaultCatalogSyncService: CatalogSyncService {
    private let steelPathSuffix = "#steelPath"
    private let maxIntrinsicLevel = 10

    func syncCatalogs(with profileModel: Profile, against catalog: MasteryCatalog) -> [CatalogContainer] {
        let items = profileModel.items
        let itemsDictionary = Dictionary(items.map { ($0.type, $0) }, uniquingKeysWith: { first, _ in first })

        var catalogs = catalog.items

        catalogs.indices.forEach { index in
            let unsyncedItems = catalogs[index].masteryItems
            var syncedItems: [MasteryItem] = []

            unsyncedItems.forEach {
                let profileItem = itemsDictionary[$0.catalogItemModel.uniqueName]
                let masteryItem = MasteryItem(profileItemModel: profileItem, catalogItemModel: $0.catalogItemModel)
                syncedItems.append(masteryItem)
            }
            catalogs[index].set(masteryItems: syncedItems.sorted {
                $0.catalogItemModel.name < $1.catalogItemModel.name
            })
        }

        return catalogs
    }

    func syncNonItemSources(with profileModel: Profile, against catalog: MasteryCatalog) -> [MasteryCategoryModel] {
        let missionsDictionary = Dictionary(profileModel.missions.map { ($0.tag, $0) }, uniquingKeysWith: { first, _ in first })
        let playerSkills = profileModel.playerSkills

        var categories = catalog.nonItemSources

        categories.indices.forEach { index in
            let unsyncedSources = categories[index].sources
            var syncedSources: [MasterySourceModel] = []

            unsyncedSources.forEach {
                let isMastered = isMastered(uniqueName: $0.uniqueName, missions: missionsDictionary, playerSkills: playerSkills)
                let masterySource = MasterySourceModel(uniqueName: $0.uniqueName, name: $0.name, mastery: $0.mastery, isMastered: isMastered)
                syncedSources.append(masterySource)
            }
            categories[index].set(sources: syncedSources.sorted {
                $0.name < $1.name
            })
        }

        return categories
    }

    private func isMastered(uniqueName: String, missions: [String: ResultMission], playerSkills: [String: Int]) -> Bool {
        if uniqueName.hasSuffix(steelPathSuffix) {
            let tag = String(uniqueName.dropLast(steelPathSuffix.count))
            return missions[tag]?.tier != nil
        }
        if let mission = missions[uniqueName] {
            return mission.completes > 0
        }
        if let level = playerSkills[uniqueName] {
            return level >= maxIntrinsicLevel
        }
        return false
    }
    
    static func makeCatalogs(from catalogItems: [MasteryItem]) -> [CatalogContainer] {
        var catalogs: [CatalogContainer] = []
        CatalogItemModel.Category.allCases.forEach { category in
            catalogs.append(.init(category: category,
                                  masteryItems:
                                    catalogItems.filter {
                $0.catalogItemModel.category == category
            }))
        }
        return catalogs.sorted {
            $0.category.displayName < $1.category.displayName
        }
    }
}
