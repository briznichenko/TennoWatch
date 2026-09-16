//
//  MasteryItemContainer.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/8/26.
//
import Foundation

struct CatalogContainer: Identifiable, Hashable {
    // MARK: - Object Properties
    let category: CatalogItemModel.Category
    private(set) var masteryItems: [MasteryItem]
    let id = UUID()

    // MARK: - Computed Properties
    var itemsCount: Int { masteryItems.count }
    var masteredItemsCount: Int { masteryItems.filter(\.isMastered).count }

    var obtainableItemsCount: Int { masteryItems.filter(\.obtainable).count }
    var obtainableRemainingCount: Int {
        masteryItems.filter { $0.obtainable && !$0.isMastered }.count
    }

    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }

    // MARK: - Functions
    mutating func set(masteryItems: [MasteryItem]) {
        self.masteryItems = masteryItems
    }
}

extension CatalogContainer: PersistentModelConvertible {
    var model: CatalogContainerModel {
        .init(category: category, masteryItems: masteryItems.map(\.model))
    }
}
