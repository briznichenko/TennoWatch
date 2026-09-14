//
//  CatalogRepository.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

enum SyncPolicy: Equatable { case daily }

protocol CatalogRepository {
    var syncPolicy: SyncPolicy { get }

    func ensureCatalogAvailable() async throws
    func syncCatalog() async throws
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
            try context.save()
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
