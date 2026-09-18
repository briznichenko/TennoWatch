//
//  CatalogSyncService.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

protocol CatalogSyncService: Sendable {
    func mergeProfile(_ profile: Profile, into items: [MasteryItem]) -> [MasteryItem]
    func mergeProfile(_ profile: Profile, into sources: [MasterySourceModel]) -> [MasterySourceModel]
}

struct DefaultCatalogSyncService: CatalogSyncService {
    // MARK: - Object Properties
    private let steelPathSuffix = "#steelPath"
    private let maxIntrinsicLevel = 10

    // MARK: - Functions
    func mergeProfile(_ profile: Profile, into items: [MasteryItem]) -> [MasteryItem] {
        let profileItems = Dictionary(
            profile.items.map { ($0.type, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        return items.map {
            MasteryItem(
                profileItemModel: profileItems[$0.catalogItemModel.uniqueName] ?? $0.profileItemModel,
                catalogItemModel: $0.catalogItemModel
            )
        }
    }

    func mergeProfile(_ profile: Profile, into sources: [MasterySourceModel]) -> [MasterySourceModel] {
        let missions = Dictionary(
            profile.missions.map { ($0.tag, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let playerSkills = profile.playerSkills

        return sources.map {
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
    }

    // MARK: - Helper Functions
    private func isMastered(
        uniqueName: String,
        missions: [String: ResultMission],
        playerSkills: [String: Int]
    ) -> Bool {
        if uniqueName.hasSuffix(steelPathSuffix) {
            let tag = String(uniqueName.dropLast(steelPathSuffix.count))
            return missions[tag]?.tier == 1
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
