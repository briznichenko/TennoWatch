//
//  MasteryCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import SwiftUI

struct MasteryCategoryDetailView: View {
    typealias Filter = MasteryCategoryDetailViewModel.Filter
    typealias SortOption = MasteryCategoryDetailViewModel.SortOption

    // MARK: - Object Properties
    @State private var viewModel: MasteryCategoryDetailViewModel

    // MARK: - Init
    init(viewModel: MasteryCategoryDetailViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        ThemedList {
            ForEach(viewModel.sortedItems, id: \.self) { item in
                MasteryItemView(viewModel: .init(item: item))
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: Strings.Common.searchItems)
        .overlay {
            if viewModel.isLoading {
                LotusLoaderView()
            }
        }
        .safeAreaInset(edge: .top) {
            FilterPills(options: Filter.allCases, title: \.title, selection: $viewModel.filter)
                .padding(.horizontal)
                .background(Color.bg)
                .clipShape(RoundedRectangle(cornerRadius: Layout.filterCornerRadius))
                .padding(.vertical, Layout.filterVerticalPadding)
        }
        .navigationTitle(viewModel.category.displayName.sentenceCased)
        .inlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker(Strings.Mastery.sortBy, selection: $viewModel.sortOption) {
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
        .task {
            await viewModel.load()
        }
    }
}

private struct Layout {
    static let filterVerticalPadding: CGFloat = 8
    static let filterCornerRadius: CGFloat = 16
}
