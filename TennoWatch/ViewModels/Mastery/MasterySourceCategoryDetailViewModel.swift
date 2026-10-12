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

    var searchText = ""
    var filter: Filter = .missing
    var sortOption: SortOption = .name

    // MARK: - Computed Properties
    var sortedItems: [MasterySourceModel] {
        let filtered = (category?.sources ?? []).filter {
            $0.mastery > 0 && filter.matches($0.masteryState) && ($0.name.matchesSearch(searchText) || $0.uniqueName.matchesSearch(searchText))
        }
        switch sortOption {
        case .name: return filtered.sorted { $0.name < $1.name }
        case .pointsRemaining:
            return filtered.sorted {
                let lhs = $0.isMastered == true ? 0 : $0.mastery
                let rhs = $1.isMastered == true ? 0 : $1.mastery
                return lhs == rhs ? $0.name < $1.name : lhs > rhs
            }
        }
    }

    var isStarChartCategory: Bool {
        categoryName == MasterySourceType.nodes.rawValue || categoryName == MasterySourceType.junctions.rawValue
    }

    var starChartSections: [StarChartSection<MasterySourceModel>] {
        StarChartMode.sections(from: sortedItems, mode: \.starChartMode)
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
            category = try await catalogRepository.getMasterySources(named: .init(rawValue: categoryName))
        } catch {
            errorManager.append(error)
        }
    }
}
