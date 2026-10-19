//
//  OpeningsItemCategoryDetailViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/4/26.
//

import Observation

@Observable
final class OpeningsItemCategoryDetailViewModel {
    let categoryTitle: String
    let items: [MasteryItemViewModel]
    var searchText = ""

    var filteredItems: [MasteryItemViewModel] {
        items.filter { $0.name.matchesSearch(searchText) || $0.uniqueName.matchesSearch(searchText) }
    }

    init(categoryTitle: String, items: [MasteryItemViewModel], searchText: String = "") {
        self.categoryTitle = categoryTitle
        self.items = items
        self.searchText = searchText
    }
}
