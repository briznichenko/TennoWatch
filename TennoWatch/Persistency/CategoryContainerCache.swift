//
//  CategoryContainerCache.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import Foundation

// An in-memory cache for `CatalogContainer` keyed by category, shared across every
// `MasteryCategoryDetailViewModel` a user might navigate into. Several MainActor-isolated
// view models can read/write it concurrently (one per pushed detail screen, plus the
// background prefetch in `MasteryViewModel`), so the storage itself needs its own
// isolation rather than trusting callers to serialize access — that's exactly what an
// actor buys you: `storage` can only ever be touched from inside this actor's methods,
// so there's no dictionary-mutated-from-two-places-at-once race to reason about.
actor CategoryContainerCache {
    // MARK: - Object Properties
    private var storage: [CatalogItemModel.Category: CatalogContainer] = [:]

    // MARK: - Functions
    func value(for category: CatalogItemModel.Category) -> CatalogContainer? {
        storage[category]
    }

    func store(_ container: CatalogContainer, for category: CatalogItemModel.Category) {
        storage[category] = container
    }
}
