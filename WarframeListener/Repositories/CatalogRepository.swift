//
//  CatalogRepository.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

enum SyncPolicy { case daily }

protocol CatalogRepository {
    var syncPolicy: SyncPolicy { get }
    
    func getMasteryCatalog() async throws -> MasteryCatalog
    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog
}

final class PersistentCatalogRepository: CatalogRepository {
    enum CatalogError: Error {
        case wrongFilename
        case noCatalogAvailable
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
    func getMasteryCatalog() async throws -> MasteryCatalog {
        var catalogs = try await persistencyService.fetchModel(by: MasteryCatalogDataModel.self)
        if catalogs.isEmpty {
            let container = try await fetchCatalog()
            catalogs.append(container)
            try await persistencyService.saveValues(catalogs)
        }
        guard let catalog = catalogs.first else {
            throw CatalogError.noCatalogAvailable
        }
        return catalog
    }
    
    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog {
        var catalog = try await getMasteryCatalog()
        catalog.items = catalogSyncService.syncCatalogs(with: profileModel, against: catalog)
        catalog.nonItemSources = catalogSyncService.syncNonItemSources(with: profileModel, against: catalog)
        return try await persistencyService.perform { context in
            try Self.apply(catalog, to: context)
        }
    }

    // MARK: - Helper Functions
    private func fetchCatalog(filename: String = "masterycatalog") async throws -> MasteryCatalog {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw CatalogError.wrongFilename
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let container = try decoder.decode(MasteryCatalogContainer.self, from: data)
        return .init(container: container)
    }

    private static func apply(_ syncedCatalog: MasteryCatalog, to context: ModelContext) throws -> MasteryCatalog {
        guard let catalogModel = try context.fetch(FetchDescriptor<MasteryCatalogDataModel>()).first else {
            throw CatalogError.noCatalogAvailable
        }

        let syncedMasteryItems = Dictionary(
            syncedCatalog.items.flatMap(\.masteryItems).map { ($0.catalogItemModel.uniqueName, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        catalogModel.items.forEach { container in
            container.masteryItems.forEach { masteryItem in
                guard let synced = syncedMasteryItems[masteryItem.catalogItem.uniqueName],
                      let profileItemModel = synced.profileItemModel else { return }
                masteryItem.set(profileItemModel: profileItemModel)
            }
        }

        let syncedSources = Dictionary(
            syncedCatalog.nonItemSources.flatMap(\.sources).map { ($0.uniqueName, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        catalogModel.nonItemSources.forEach { category in
            category.sources.forEach { source in
                guard let synced = syncedSources[source.uniqueName] else { return }
                source.isMastered = synced.isMastered ?? false
            }
        }

        try context.save()
        return catalogModel.value
    }
}
