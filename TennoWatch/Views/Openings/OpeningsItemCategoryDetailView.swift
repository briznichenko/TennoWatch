//
//  OpeningsItemCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsItemCategoryDetailView: View {
    @State private var viewModel: OpeningsItemCategoryDetailViewModel

    init(viewModel: OpeningsItemCategoryDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ThemedList {
            ForEach(viewModel.filteredItems) { item in
                MasteryItemView(viewModel: item)
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: Strings.Common.searchItems)
        .navigationTitle(viewModel.categoryTitle)
        .inlineNavigationTitle()
    }
}
