//
//  CatalogSyncService.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

protocol CatalogSyncService: Sendable {
    func syncCatalogs(with profile: ProfileDataModel, against catalog: MasteryCatalogDataModel)
    func syncNonItemSources(with profile: ProfileDataModel, against catalog: MasteryCatalogDataModel)
}

struct DefaultCatalogSyncService: CatalogSyncService {
    // MARK: - Object Properties
    private let steelPathSuffix = "#steelPath"
    private let maxIntrinsicLevel = 10

    // MARK: - Functions
    func syncCatalogs(with profile: ProfileDataModel, against catalog: MasteryCatalogDataModel) {
        let profileItems = Dictionary(
            profile.items.map { ($0.type, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        for container in catalog.items {
            for masteryItem in container.masteryItems {
                masteryItem.profileItem = profileItems[masteryItem.catalogItem.uniqueName]
            }
        }
    }

    func syncNonItemSources(with profile: ProfileDataModel, against catalog: MasteryCatalogDataModel) {
        let missions = Dictionary(
            profile.missions.map { ($0.tag, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let playerSkills = Dictionary(
            profile.playerSkills.map { ($0.name, $0.rank) },
            uniquingKeysWith: { first, _ in first }
        )

        for category in catalog.nonItemSources {
            for source in category.sources {
                source.isMastered = isMastered(
                    uniqueName: source.uniqueName,
                    missions: missions,
                    playerSkills: playerSkills
                )
            }
        }
    }

    // MARK: - Helper Functions
    private func isMastered(
        uniqueName: String,
        missions: [String: ResultMissionDataModel],
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

    static func makeCatalogs(from catalogItems: [MasteryItemDataModel]) -> [CatalogContainerModel] {
        CatalogItemModel.Category.allCases
            .map { category in
                CatalogContainerModel(
                    category: category,
                    masteryItems: catalogItems.filter { $0.catalogItem.category == category }
                )
            }
            .sorted { $0.category.displayName < $1.category.displayName }
    }
}
