//
//  MasteryItemContainer.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/8/26.
//
import Foundation

struct MasteryItemContainer: Identifiable, Hashable {
    let id = UUID()
    let catalogItem: CatalogItemModel
    let profileItem: ProfileItemModel?
}

struct Category: Identifiable, Hashable {
    let id = UUID()
    let category: CatalogItemModel.Category
    let items: [CatalogItemModel]
}

struct CatalogContainer: Identifiable, Hashable {
    let category: Category
    private(set) var masteryItems: [MasteryItemContainer]
    var itemsCount: Int { masteryItems.count }
    var masteredItemsCount: Int {
        masteryItems.filter { item in
            let xp = item.profileItem?.xp ?? 0
            let isMastered = Int(Double(xp / item.catalogItem.xpPerRankSq).squareRoot()) >= item.catalogItem.maxRank
            return isMastered
        }.count
    }
    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
    let id = UUID()
    
    init(category: Category) {
        self.category = category
        masteryItems = category.items.map { MasteryItemContainer(catalogItem: $0, profileItem: .none) }
    }
    
    mutating func set(masteryItems: [MasteryItemContainer]) {
        self.masteryItems = masteryItems
    }
}
