//
//  ProfileItemsListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileItemsListView: View {
    typealias SortOption = ProfileItemsListViewModel.SortOption

    // MARK: - Object Properties
    @State private var viewModel: ProfileItemsListViewModel

    // MARK: - Init
    init(viewModel: ProfileItemsListViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(viewModel.sortedItems) { item in
                ProfileItemStatRowView(item: item)
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: Strings.Profile.searchPlaceholder)
        .navigationTitle(Strings.Profile.itemsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(Strings.Profile.sortBy, selection: $viewModel.sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
}
