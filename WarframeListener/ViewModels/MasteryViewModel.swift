//
//  MasteryViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

enum MasteryItemType: String, CaseIterable {
    case weapon = "Weapons"
    case warframe = "Powersuits"
    case other
}

@Observable
final class MasteryViewModel {
    private(set) var statusText: String = ""
    private(set) var catalogs: [Catalog] = []
    
    func fetchCatalog(filename: String = "masterycatalog") async {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            statusText = "wrong \(filename)"
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let catalogContainer = try decoder.decode(CatalogContainer.self, from: data)
                filterCatalogItems(catalogContainer.items)
            } catch let DecodingError.keyNotFound(key, context) {
                statusText = "Missing Key: \(key.stringValue), Path: \(context.codingPath)"
            } catch let DecodingError.typeMismatch(type, context) {
                statusText = "Type Mismatch: \(type), Path: \(context.codingPath)"
            } catch let DecodingError.valueNotFound(value, context) {
                statusText = "Value Null: \(value), Path: \(context.codingPath)"
            } catch {
                statusText = "Error: \(error)"
            }
    }
    
    private func filterCatalogItems(_ catalogItems: [CatalogItem]) {
        CatalogItem.Category.allCases.forEach { category in
            let catalog = Catalog(category: category, items: catalogItems.filter { $0.category == category })
            catalogs.append(catalog)
        }
    }
}
