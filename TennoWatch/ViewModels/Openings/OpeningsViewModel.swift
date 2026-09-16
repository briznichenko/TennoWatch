//
//  OpeningsViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Foundation
import Observation

struct OpeningsItemCategorySummary: Identifiable, Hashable {
    let category: CatalogItemModel.Category
    let count: Int
    var id: CatalogItemModel.Category { category }
    var countText: String { "\(count)" }
}

struct OpeningsSourceCategorySummary: Identifiable, Hashable {
    let name: String
    let count: Int
    var id: String { name }
    var countText: String { "\(count)" }
}

@Observable
final class OpeningsViewModel {
    // MARK: - Object Properties
    private let profileRepository: ProfileRepository
    private let catalogRepository: CatalogRepository
    private let worldStateRepository: WorldStateRepository
    private let matchingService: OpeningsMatchingService
    let errorManager: ErrorManager

    private(set) var catalog: MasteryCatalog?
    private(set) var worldState: WorldState?
    private(set) var isLoading = false

    // MARK: - Computed Properties
    private var unmasteredItems: [MasteryItem] {
        (catalog?.items.flatMap(\.masteryItems) ?? []).filter { $0.obtainable && !$0.isMastered }
    }

    private var matchedOpenings: [TimeSensitiveOpening] {
        guard let worldState else { return [] }
        return matchingService.timeSensitiveOpenings(for: unmasteredItems, in: worldState)
    }

    private var permanentMasteryItems: [MasteryItem] {
        let timeSensitiveIDs = Set(matchedOpenings.map(\.id))
        return unmasteredItems.filter { !timeSensitiveIDs.contains($0.catalogItemModel.uniqueName) }
    }

    /// Non-item sources grouped by their source category name, keeping only
    /// categories that still have an unmastered source left.
    private var permanentSourceGroups: [(name: String, sources: [MasterySourceModel])] {
        (catalog?.nonItemSources ?? []).compactMap { category in
            let unmastered = category.sources.filter { $0.isMastered != true }
            return unmastered.isEmpty ? nil : (category.name, unmastered)
        }
    }

    var timeSensitiveOpenings: [TimeSensitiveOpeningViewModel] {
        matchedOpenings
            .sorted { $0.item.catalogItemModel.name < $1.item.catalogItemModel.name }
            .map { TimeSensitiveOpeningViewModel(opening: $0) }
    }

    var permanentItemCategories: [OpeningsItemCategorySummary] {
        Dictionary(grouping: permanentMasteryItems, by: \.catalogItemModel.category)
            .map { OpeningsItemCategorySummary(category: $0.key, count: $0.value.count) }
            .sorted { $0.category.displayName < $1.category.displayName }
    }

    var permanentSourceCategories: [OpeningsSourceCategorySummary] {
        permanentSourceGroups
            .map { OpeningsSourceCategorySummary(name: $0.name, count: $0.sources.count) }
            .sorted { $0.name < $1.name }
    }

    // MARK: - Init
    init(
        profileRepository: ProfileRepository,
        catalogRepository: CatalogRepository,
        worldStateRepository: WorldStateRepository,
        matchingService: OpeningsMatchingService = DefaultOpeningsMatchingService(),
        errorManager: ErrorManager
    ) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.worldStateRepository = worldStateRepository
        self.matchingService = matchingService
        self.errorManager = errorManager
    }

    // MARK: - Functions
    // `async let` over `withTaskGroup` here on purpose: there are exactly two independent
    // fetches, both spelled out at the call site, and that count never changes. TaskGroup
    // earns its keep when the number of concurrent children is dynamic — see
    // `MasteryViewModel.prefetchCategoryContainers()`, which fans out over
    // `CatalogItemModel.Category.allCases` — but for a small, fixed arity like this one,
    // `async let` says the same thing with less ceremony.
    func fetchOpenings() async {
        isLoading = true
        defer { isLoading = false }

        async let fetchedCatalog = fetchCatalog()
        async let fetchedWorldState = fetchWorldState()
        catalog = await fetchedCatalog
        worldState = await fetchedWorldState
    }

    func permanentItems(in category: CatalogItemModel.Category) -> [MasteryItemViewModel] {
        permanentMasteryItems
            .filter { $0.catalogItemModel.category == category }
            .sorted { $0.catalogItemModel.name < $1.catalogItemModel.name }
            .map { MasteryItemViewModel(item: $0) }
    }

    func permanentSources(in categoryName: String) -> [MasterySourceViewModel] {
        (permanentSourceGroups.first { $0.name == categoryName }?.sources ?? [])
            .sorted { $0.name < $1.name }
            .map { MasterySourceViewModel(source: $0) }
    }

    // MARK: - Helper Functions
    private func fetchCatalog() async -> MasteryCatalog? {
        do {
            if let profile = try? await profileRepository.getProfile() {
                return try await catalogRepository.syncMasteryCatalog(with: profile)
            }
            return try await catalogRepository.getMasteryCatalog()
        } catch {
            errorManager.append(error)
            return nil
        }
    }

    private func fetchWorldState() async -> WorldState? {
        do {
            return try await worldStateRepository.getWorldState()
        } catch {
            errorManager.append(error)
            return nil
        }
    }
}
