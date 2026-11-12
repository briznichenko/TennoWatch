//
//  OpeningsItemCategoryDetailViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/4/26.
//

import Observation

@Observable
@MainActor
final class OpeningsItemCategoryDetailViewModel {
    let categoryTitle: String
    private(set) var items: [MasteryItemViewModel]
    var searchText = ""
    private let reloadItems: (() async -> [MasteryItemViewModel])?

    var filteredItems: [MasteryItemViewModel] {
        items.filter { $0.name.matchesSearch(searchText) || $0.uniqueName.matchesSearch(searchText) }
    }

    func load() async {
        if let reloadItems { items = await reloadItems() }
    }

    init(categoryTitle: String, items: [MasteryItemViewModel], searchText: String = "", reloadItems: (() async -> [MasteryItemViewModel])? = nil) {
        self.reloadItems = reloadItems
        self.categoryTitle = categoryTitle
        self.items = items
        self.searchText = searchText
    }
}
