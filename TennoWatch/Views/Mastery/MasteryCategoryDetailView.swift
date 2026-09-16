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
        List {
            ForEach(viewModel.sortedItems, id: \.self) { item in
                MasteryItemView(viewModel: .init(item: item))
            }
        }
        .listStyle(.plain)
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
        .navigationTitle(viewModel.category.displayName.sentenceCased)
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
