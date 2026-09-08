//
//  MasteryItemContainer.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/8/26.
//
import Foundation

struct CatalogContainer: Identifiable, Hashable {
    let category: CatalogItemModel.Category
    private(set) var masteryItems: [MasteryItem]
    var itemsCount: Int { masteryItems.count }
    var masteredItemsCount: Int {
        masteryItems.filter { item in
            let xp = item.profileItemModel?.xp ?? 0
            let isMastered = Int(Double(xp / item.catalogItemModel.xpPerRankSq).squareRoot()) >= item.catalogItemModel.maxRank
            return isMastered
        }.count
    }
    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
    let id = UUID()
    
    mutating func set(masteryItems: [MasteryItem]) {
        self.masteryItems = masteryItems
    }
}
