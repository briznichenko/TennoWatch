//
//  CatalogRepository.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation

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
    
    let syncPolicy: SyncPolicy
    private let persistencyService: PersistencyService
    private let catalogSyncService: CatalogSyncService

    init(syncPolicy: SyncPolicy = .daily, persistencyService: PersistencyService, catalogSyncService: CatalogSyncService = DefaultCatalogSyncService()) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
        self.catalogSyncService = catalogSyncService
    }
    
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
        try await persistencyService.saveValue(catalog)
        return catalog
    }

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
}
