//
//  MasterySourceCategoryDetailViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import Foundation
import Observation

@Observable
final class MasterySourceCategoryDetailViewModel {
    typealias Filter = MasteryCategoryDetailViewModel.Filter
    typealias SortOption = MasteryCategoryDetailViewModel.SortOption

    // MARK: - Object Properties
    let categoryName: String
    private let catalogRepository: CatalogRepository
    private let errorManager: ErrorManager

    private(set) var category: MasteryCategoryModel?
    private(set) var isLoading = false

    var filter: Filter = .missing
    var sortOption: SortOption = .name

    // MARK: - Computed Properties
    var sortedItems: [MasterySourceModel] {
        let filtered = (category?.sources ?? []).filter { filter.matches($0.masteryState) }
        switch sortOption {
        case .name: return filtered.sorted { $0.name < $1.name }
        case .pointsRemaining: return filtered.sorted { $0.mastery < $1.mastery }
        }
    }

    // MARK: - Init
    init(categoryName: String, catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.categoryName = categoryName
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func load() async {
        guard category == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            category = try await catalogRepository.getMasterySources(named: categoryName)
        } catch {
            errorManager.append(error)
        }
    }
}
