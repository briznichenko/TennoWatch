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
    
    func getCatalogs() async throws -> [CatalogContainer]
    func syncCatalogs(with profileModel: Profile) async throws -> [CatalogContainer]
}

final class PersistentCatalogRepository: CatalogRepository {
    enum CatalogError: Error {
        case wrongFilename
    }
    
    let syncPolicy: SyncPolicy
    private let persistencyService: PersistencyService
    
    init(syncPolicy: SyncPolicy = .daily, persistencyService: PersistencyService) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
    }
    
    
    func getCatalogs() async throws -> [CatalogContainer] {
        var items = try await persistencyService.fetchModel(by: MasteryItemDataModel.self)
        if items.isEmpty {
            items = try await fetchCatalog().items.map { .init(profileItemModel: .none, catalogItemModel: $0) }
        }
        return filterCatalogItemModels(items)
    }
    
    func syncCatalogs(with profileModel: Profile) async throws -> [CatalogContainer] {
        let items = profileModel.items
        let itemsDictionary: [String: ProfileItemModel] = items.map { [$0.type: $0] }.reduce(into: [:]) { result, dict in
            for (key, value) in dict {
                result[key] = value
            }
        }
        
        var catalogs = try await getCatalogs()
        var itemsToSave: [MasteryItem] = []
        
        catalogs.indices.forEach { index in
            let unsyncedItems = catalogs[index].masteryItems
            var syncedItems: [MasteryItem] = []
            
            unsyncedItems.forEach {
                let profileItem = itemsDictionary[$0.catalogItemModel.uniqueName]
                let masteryItem: MasteryItem = .init(profileItemModel: profileItem, catalogItemModel: $0.catalogItemModel)
                itemsToSave.append(masteryItem)
                syncedItems.append(masteryItem)
            }
            catalogs[index].set(masteryItems: syncedItems.sorted {
                $0.catalogItemModel.name < $1.catalogItemModel.name
            })
        }
        
        for item in itemsToSave {
            try await persistencyService.saveValue(value: item)
        }
        
        return catalogs
    }
    
    private func filterCatalogItemModels(_ catalogItems: [MasteryItem]) -> [CatalogContainer] {
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
