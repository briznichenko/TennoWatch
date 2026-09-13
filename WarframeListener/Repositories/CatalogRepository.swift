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
    
    init(syncPolicy: SyncPolicy = .daily, persistencyService: PersistencyService) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
    }
    
    func getMasteryCatalog() async throws -> MasteryCatalog {
        var catalogs = try await persistencyService.fetchModel(by: MasteryCatalogDataModel.self)
        if catalogs.isEmpty {
            var container = try await fetchCatalog()
            container.catalogs = makeCatalogs(from: container.items)
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
        catalog.catalogs = try await syncCatalogs(with: profileModel, against: catalog)
        try await persistencyService.saveValue(catalog)
        return catalog
    }
    
    func syncCatalogs(with profileModel: Profile, against catalog: MasteryCatalog) async throws -> [CatalogContainer] {
        let items = profileModel.items
        let itemsDictionary = Dictionary(items.map { ($0.type, $0) }, uniquingKeysWith: { first, _ in first })
        
        var catalogs = catalog.catalogs
        
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
    
    private func makeCatalogs(from catalogItems: [MasteryItem]) -> [CatalogContainer] {
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
