//
//  MasteryCategoryDetailViewModel.swift
//  WarframeListener
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
    init(category: CatalogItemModel.Category, catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.category = category
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func load() async {
        guard container == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            container = try await catalogRepository.getCatalogContainer(for: category)
        } catch {
            errorManager.append(error)
        }
    }
}
