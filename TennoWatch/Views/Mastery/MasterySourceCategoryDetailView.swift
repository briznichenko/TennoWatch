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
            ForEach(viewModel.sortedItems, id: \.self) { item in
                MasterySourceView(viewModel: .init(source: item))
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .safeAreaInset(edge: .top) {
            FilterPills(options: Filter.allCases, title: \.title, selection: $viewModel.filter)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.bg)
        }
        .navigationTitle(viewModel.categoryName.sentenceCased)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
