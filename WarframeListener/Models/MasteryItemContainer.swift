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
    var masteredItemsCount: Int { masteryItems.filter(\.isMastered).count }

    var obtainableItemsCount: Int { masteryItems.filter(\.obtainable).count }
    var obtainableRemainingCount: Int {
        masteryItems.filter { $0.obtainable && !$0.isMastered }.count
    }

    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
    let id = UUID()
    
    mutating func set(masteryItems: [MasteryItem]) {
        self.masteryItems = masteryItems
    }
}
