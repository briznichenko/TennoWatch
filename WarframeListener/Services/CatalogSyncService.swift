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
    // MARK: - Object Properties
    private let steelPathSuffix = "#steelPath"
    private let maxIntrinsicLevel = 10

    // MARK: - Functions
    func syncCatalogs(with profile: Profile, against catalog: MasteryCatalog) -> [CatalogContainer] {
        let profileItems = Dictionary(
            profile.items.map { ($0.type, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        return catalog.items.map { container in
            var container = container
            container.set(
                masteryItems: container.masteryItems
                    .map {
                        MasteryItem(
                            profileItemModel: profileItems[$0.catalogItemModel.uniqueName],
                            catalogItemModel: $0.catalogItemModel
                        )
                    }
                    .sorted {
                        $0.catalogItemModel.name < $1.catalogItemModel.name
                    }
            )
            return container
        }
    }

    func syncNonItemSources(with profile: Profile, against catalog: MasteryCatalog) -> [MasteryCategoryModel] {
        let missions = Dictionary(
            profile.missions.map { ($0.tag, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let playerSkills = profile.playerSkills

        return catalog.nonItemSources.map { category in
            var category = category

            category.set(
                sources: category.sources
                    .map {
                        MasterySourceModel(
                            uniqueName: $0.uniqueName,
                            name: $0.name,
                            mastery: $0.mastery,
                            isMastered: isMastered(
                                uniqueName: $0.uniqueName,
                                missions: missions,
                                playerSkills: playerSkills
                            )
                        )
                    }
                    .sorted { $0.name < $1.name }
            )

            return category
        }
    }

    // MARK: - Helper Functions
    private func isMastered(
        uniqueName: String,
        missions: [String: ResultMission],
        playerSkills: [String: Int]
    ) -> Bool {
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
        var catalogs: Set<CatalogContainer> = []
        CatalogItemModel.Category.allCases.forEach { category in
            catalogs.insert(.init(category: category,
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
