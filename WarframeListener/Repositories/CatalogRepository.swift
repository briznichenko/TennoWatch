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
    
    func getCatalog() async throws -> MasteryCatalogContainer
    func syncCatalog() async throws -> MasteryCatalogContainer
}

final class PersistentCatalogRepository: CatalogRepository {
    enum CatalogError: Error {
        case wrongFilename
    }
    
    let syncPolicy: SyncPolicy
    private let persistencyService: PersistencyService
    
    func getCatalog() async throws -> MasteryCatalogContainer {
        try await fetchCatalog()
    }
    
    func syncCatalog() async throws -> MasteryCatalogContainer {
        try await fetchCatalog()
    }
    
    init(syncPolicy: SyncPolicy = .daily, persistencyService: PersistencyService) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
    }
    
    private func fetchCatalog(filename: String = "masterycatalog") async throws -> MasteryCatalogContainer {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw CatalogError.wrongFilename
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MasteryCatalogContainer.self, from: data)
    }
}
