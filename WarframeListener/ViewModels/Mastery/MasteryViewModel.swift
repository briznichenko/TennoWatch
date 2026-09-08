//
//  MasteryViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

@Observable
final class MasteryViewModel {
    private(set) var statusText: String = ""
    private(set) var catalogs: [CatalogContainer] = []
    private(set) var isLoading: Bool = false
    
    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository
    
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
    }
    
    func fetchAll() async {
        await fetchCatalog()
        await fetchProfile()
    }
    
    func fetchCatalog() async {
        do {
            let items = try await catalogRepository.getCatalog().items
            catalogs = filterCatalogItemModels(items)
        } catch {
            statusText = error.localizedDescription
        }
    }
    
    func fetchProfile() async {
        defer {
            isLoading = false
        }
        
        isLoading = true
        statusText = "Loading..."

        do {
            let profile = try await profileRepository.getProfile(withPlayerId: .none)
            setProfileItemModels(profile.items)
        } catch {
            statusText = error.localizedDescription
        }
    }
    
    private func setProfileItemModels(_ items: [ProfileItemModel]) {
        let itemsDictionary: [String: ProfileItemModel] = items.map { [$0.type: $0] }.reduce(into: [:]) { result, dict in
            for (key, value) in dict {
                result[key] = value
            }
        }
        catalogs.indices.forEach { index in
            let unsyncedItems = catalogs[index].masteryItems
            var syncedItems: [MasteryItemContainer] = []
            
            unsyncedItems.forEach {
                let profileItem = itemsDictionary[$0.catalogItem.uniqueName]
                syncedItems.append(.init(catalogItem: $0.catalogItem, profileItem: profileItem))
            }
            catalogs[index].set(masteryItems: syncedItems.sorted {
                $0.catalogItem.name < $1.catalogItem.name
            })
        }
    }
    
    private func filterCatalogItemModels(_ catalogItems: [CatalogItemModel]) -> [CatalogContainer] {
        var catalogs: [CatalogContainer] = []
        CatalogItemModel.Category.allCases.forEach { category in
            let category = Category(category: category, items: catalogItems.filter { $0.category == category })
            catalogs.append(.init(category: category))
        }
        return catalogs.sorted {
            $0.category.category.displayName < $1.category.category.displayName
        }
    }
}
