//
//  MasteryCategoryDetailViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import Foundation
import Observation

@Observable
final class MasteryCategoryDetailViewModel {
    enum Filter: String, CaseIterable, Identifiable, Hashable {
        case missing, mastered, locked

        var id: String { rawValue }
        var title: String {
            switch self {
            case .missing: Strings.Mastery.filterMissing
            case .mastered: Strings.Mastery.filterMastered
            case .locked: Strings.Mastery.filterLocked
            }
        }

        func matches(_ state: MasteryItem.MasteryState) -> Bool {
            switch self {
            case .missing: state == .unmastered || state == .partiallyMastered
            case .mastered: state == .mastered
            case .locked: state == .unobtainable
            }
        }
    }

    enum SortOption: String, CaseIterable, Identifiable, Hashable {
        case name, pointsRemaining

        var id: String { rawValue }
        var title: String {
            switch self {
            case .name: Strings.Mastery.sortOptionName
            case .pointsRemaining: Strings.Mastery.sortOptionPointsRemaining
            }
        }
    }

    // MARK: - Object Properties
    let category: CatalogItemModel.Category
    private let catalogRepository: CatalogRepository
    private let categoryContainerCache: CategoryContainerCache
    private let errorManager: ErrorManager

    private(set) var container: CatalogContainer?
    private(set) var isLoading = false

    var filter: Filter = .missing
    var sortOption: SortOption = .name

    // MARK: - Computed Properties
    var sortedItems: [MasteryItem] {
        let filtered = (container?.masteryItems ?? []).filter { filter.matches($0.masteryState) }
        switch sortOption {
        case .name: return filtered.sorted { $0.catalogItemModel.name < $1.catalogItemModel.name }
        case .pointsRemaining: return filtered.sorted { $0.remainingMasteryPoints > $1.remainingMasteryPoints }
        }
    }

    // MARK: - Init
    init(
        category: CatalogItemModel.Category,
        catalogRepository: CatalogRepository,
        categoryContainerCache: CategoryContainerCache,
        errorManager: ErrorManager
    ) {
        self.category = category
        self.catalogRepository = catalogRepository
        self.categoryContainerCache = categoryContainerCache
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func load() async {
        guard container == nil else { return }

        // Cross-actor call: `categoryContainerCache` runs on its own actor, this view
        // model runs on MainActor (implicitly, via this module's default isolation), so
        // reading it is a suspension point even though it's "just a dictionary lookup" —
        // there's no such thing as a free synchronous read across an actor boundary.
        if let cached = await categoryContainerCache.value(for: category) {
            container = cached
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            let container = try await catalogRepository.getCatalogContainer(for: category)
            self.container = container
            await categoryContainerCache.store(container, for: category)
        } catch {
            errorManager.append(error)
        }
    }
}
