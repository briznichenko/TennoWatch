//
//  MasterySourceCategoryDetailView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//


import SwiftUI

struct MasterySourceCategoryDetailView: View {
    typealias Filter = MasteryCategoryDetailView.Filter

    typealias SortOption = MasteryCategoryDetailView.SortOption

    // MARK: - Object Properties
    let masteryCategory: MasteryCategoryModel

    @State private var filter: Filter = .missing
    @State private var sortOption: SortOption = .name

    // MARK: - Computed Properties
    // TODO: - Move to view model;
    private var sortedItems: [MasterySourceModel] {
        let filtered = masteryCategory.sources.filter { filter.matches($0.masteryState) }
        switch sortOption {
        case .name: return filtered.sorted { $0.name < $1.name }
        case .pointsRemaining: return filtered.sorted { $0.mastery < $1.mastery }
        }
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(sortedItems, id: \.self) { item in
                MasterySourceView(viewModel: .init(source: item))
            }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .top) {
            FilterPills(options: Filter.allCases, title: \.title, selection: $filter)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.bg)
        }
        .navigationTitle(masteryCategory.name.sentenceCased)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(Strings.Mastery.sortBy, selection: $sortOption) {
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
