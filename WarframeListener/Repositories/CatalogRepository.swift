//
//  CatalogRepository.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

enum SyncPolicy: Equatable { case daily }

struct MasterySummary: Sendable {
    struct CategoryCount: Sendable {
        let masteredCount: Int
        let itemsCount: Int
    }

    struct ItemSnapshot: Sendable {
        let rank: Int
        let masteryState: MasteryState
        let remainingMasteryPoints: Int
    }

    struct SourceSnapshot: Sendable {
        let isMastered: Bool
    }

    let rankProgress: MasteryRankProgress
    let obtainableItemsRemaining: Int
    let itemCategoryCounts: [CatalogItemModel.Category: CategoryCount]
    let sourceCategoryCounts: [String: CategoryCount]
    let itemSnapshots: [String: ItemSnapshot]
    let sourceSnapshots: [String: SourceSnapshot]
}

protocol CatalogRepository {
    var syncPolicy: SyncPolicy { get }

    func ensureCatalogAvailable() async throws
    func syncCatalog() async throws
    func fetchSummary() async throws -> MasterySummary?
}

final class PersistentCatalogRepository: CatalogRepository {
    enum CatalogError: Error {
        case wrongFilename
    }

    // MARK: - Object Properties
    let syncPolicy: SyncPolicy
    private let persistencyService: PersistencyService
    private let catalogSyncService: CatalogSyncService

    // MARK: - Init
    init(syncPolicy: SyncPolicy = .daily, persistencyService: PersistencyService, catalogSyncService: CatalogSyncService = DefaultCatalogSyncService()) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
        self.catalogSyncService = catalogSyncService
    }

    // MARK: - Functions
    func ensureCatalogAvailable() async throws {
        // Load before `perform` so the empty-check and insert happen atomically in one actor hop.
        let container = try Self.loadBundledCatalog()
        try await persistencyService.perform { context in
            guard try context.fetchCount(FetchDescriptor<MasteryCatalogDataModel>()) == 0 else { return }
            context.insert(MasteryCatalogDataModel(from: container))
            try context.save()
        }
    }

    func syncCatalog() async throws {
        let catalogSyncService = catalogSyncService
        try await persistencyService.perform { context in
            guard
                let catalog = try context.fetch(FetchDescriptor<MasteryCatalogDataModel>()).first,
                let profile = try context.fetch(FetchDescriptor<ProfileDataModel>()).first
            else { return }

            catalogSyncService.syncCatalogs(with: profile, against: catalog)
            catalogSyncService.syncNonItemSources(with: profile, against: catalog)
            catalog.lastSyncedAt = Date()
            try context.save()
        }
    }

    func fetchSummary() async throws -> MasterySummary? {
        try await persistencyService.perform { context in
            guard let catalog = try context.fetch(FetchDescriptor<MasteryCatalogDataModel>()).first else { return nil }

            let itemCounts = Dictionary(
                uniqueKeysWithValues: catalog.items.map { container in
                    (
                        container.category,
                        MasterySummary.CategoryCount(
                            masteredCount: container.masteredItemsCount,
                            itemsCount: container.itemsCount
                        )
                    )
                }
            )
            let sourceCounts = Dictionary(
                uniqueKeysWithValues: catalog.nonItemSources.map { category in
                    (
                        category.name,
                        MasterySummary.CategoryCount(
                            masteredCount: category.masteredItemsCount,
                            itemsCount: category.itemsCount
                        )
                    )
                }
            )
            let itemSnapshots = Dictionary(
                uniqueKeysWithValues: catalog.items.flatMap(\.masteryItems).map { item in
                    (
                        item.catalogItem.uniqueName,
                        MasterySummary.ItemSnapshot(
                            rank: item.rank,
                            masteryState: item.masteryState,
                            remainingMasteryPoints: item.remainingMasteryPoints
                        )
                    )
                }
            )
            let sourceSnapshots = Dictionary(
                uniqueKeysWithValues: catalog.nonItemSources.flatMap(\.sources).map { source in
                    (source.uniqueName, MasterySummary.SourceSnapshot(isMastered: source.isMastered))
                }
            )

            return MasterySummary(
                rankProgress: catalog.rankProgress,
                obtainableItemsRemaining: catalog.obtainableItemsRemaining,
                itemCategoryCounts: itemCounts,
                sourceCategoryCounts: sourceCounts,
                itemSnapshots: itemSnapshots,
                sourceSnapshots: sourceSnapshots
            )
        }
    }

    // MARK: - Helper Functions
    private static func loadBundledCatalog(filename: String = "masterycatalog") throws -> MasteryCatalogContainer {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw CatalogError.wrongFilename
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MasteryCatalogContainer.self, from: data)
    }
}
