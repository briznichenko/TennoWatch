//
//  ProfileViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Combine
import Foundation

enum MasteryItemType: String, CaseIterable {
    case weapon = "Weapons"
    case warframe = "Powersuits"
    case other
}

struct MasteryItem: Identifiable {
    private(set) var item: Weapon
    let id = UUID()
    
    var itemName: String { ExternalData.persistentItemNames[item.type] ?? item.type}
    var itemType: String { item.type }
    var itemXP: Int { item.xp ?? 0 }
    var isMastered: Bool { itemXP > 0 }
    
    static let stub = MasteryItem(item: .init(equipTime: 1, headshots: 20, hits: 10, assists: 5, kills: 20, xp: 3000, type: "Type", fired: 100))
}

@Observable
final class ProfileViewModel {
    private(set) var profile: ProfileModel?
    private(set) var networkText: String = ""
    private(set) var isLoading = false
    private(set) var items: [MasteryItemType: [MasteryItem]] = [:]
    private(set) var catalogs: [Catalog] = []
    
    var displayName: String {
        profile?.results.first?.displayName ?? "Unknown"
    }

    private let playerId: String
    private let apiManager: APIManager
    private var cancellables = Set<AnyCancellable>()

    init(playerId: String, apiManager: APIManager = APIManager()) {
        self.playerId = playerId
        self.apiManager = apiManager
    }

    func fetchProfile() async {
        isLoading = true
        networkText = "Loading..."

        do {
            profile = try await apiManager.fetch(.profile(playerId: playerId))
            filterItems()
            isLoading = false
        } catch {
            networkText = error.localizedDescription
        }
    }
    
    func fetchCatalog(filename: String = "masterycatalog") async {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            networkText = "wrong \(filename)"
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let catalogContainer = try decoder.decode(CatalogContainer.self, from: data)
                filterCatalogItems(catalogContainer.items)
            } catch let DecodingError.keyNotFound(key, context) {
                networkText = "Missing Key: \(key.stringValue), Path: \(context.codingPath)"
            } catch let DecodingError.typeMismatch(type, context) {
                networkText = "Type Mismatch: \(type), Path: \(context.codingPath)"
            } catch let DecodingError.valueNotFound(value, context) {
                networkText = "Value Null: \(value), Path: \(context.codingPath)"
            } catch {
                networkText = "Error: \(error)"
            }
    }
    
    func fetchProfileMock(filename: String = "ProfileData") async {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                profile = try decoder.decode(ProfileModel.self, from: data)
                filterItems()
            } catch {
                networkText = error.localizedDescription
            }
    }
    
    private func filterCatalogItems(_ catalogItems: [CatalogItem]) {
        CatalogItem.Category.allCases.forEach { category in
            let catalog = Catalog(category: category, items: catalogItems.filter { $0.category == category })
            catalogs.append(catalog)
        }
    }
    
    private func filterItems() {
        let xpItems = profile?.stats.weapons
            .sorted { ($0.xp ?? 0) < ($1.xp ?? 0) }
            .map { MasteryItem(item: $0) } ?? []
        var weapons: [MasteryItem] = []
        var warframes: [MasteryItem] = []
        var other: [MasteryItem] = []
        
        xpItems.forEach { item in
            let comps = item.itemType.components(separatedBy: "/")
            if comps.indices.contains(2) {
                switch MasteryItemType(rawValue: comps[2]) {
                case .weapon: weapons.append(item)
                case .warframe: warframes.append(item)
                case .other, .none: other.append(item)
                }
            }
        }
        items = [
            .other: other,
            .warframe: warframes,
            .weapon: weapons
        ]
    }
}
