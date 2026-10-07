//
//  MasterySourceCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceCategoryDetailView: View {
    typealias Filter = MasterySourceCategoryDetailViewModel.Filter
    typealias SortOption = MasterySourceCategoryDetailViewModel.SortOption

    // MARK: - Object Properties
    @State private var viewModel: MasterySourceCategoryDetailViewModel

    // MARK: - Init
    init(viewModel: MasterySourceCategoryDetailViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        List {
            if viewModel.isStarChartCategory {
                ForEach(viewModel.starChartSections) { section in
                    Section {
                        ForEach(section.items, id: \.uniqueName) { item in
                            MasterySourceView(viewModel: .init(source: item))
                        }
                    } header: {
                        SectionHeaderLabel(section.mode.title)
                    }
                }
            } else {
                ForEach(viewModel.sortedItems, id: \.uniqueName) { item in
                    MasterySourceView(viewModel: .init(source: item))
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: viewModel.isStarChartCategory ? Strings.Common.searchNodes : Strings.Common.search)
        .overlay {
            if viewModel.isLoading {
                LotusLoaderView()
            }
        }
        .safeAreaInset(edge: .top) {
            FilterPills(options: Filter.allCases, title: \.title, selection: $viewModel.filter)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.bg)
        }
        .navigationTitle(viewModel.categoryName.sentenceCased)
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
