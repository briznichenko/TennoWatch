//
//  MasteryCategoryDetailView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import SwiftUI

struct MasteryCategoryDetailView: View {
    enum Filter: String, CaseIterable, Identifiable, Hashable {
        case missing, mastered, locked

        var id: String { rawValue }
        var title: String {
            switch self {
            case .missing: Strings.Mastery.filterMissing
            case .mastered: Strings.Mastery.filterMastered
            case .locked: Strings.Mastery.filterLocked
            }
        }

        func matches(_ state: MasteryItem.MasteryState) -> Bool {
            switch self {
            case .missing: state == .unmastered || state == .partiallyMastered
            case .mastered: state == .mastered
            case .locked: state == .unobtainable
            }
        }
    }

    enum SortOption: String, CaseIterable, Identifiable, Hashable {
        case name, pointsRemaining

        var id: String { rawValue }
        var title: String {
            switch self {
            case .name: Strings.Mastery.sortOptionName
            case .pointsRemaining: Strings.Mastery.sortOptionPointsRemaining
            }
        }
    }

    // MARK: - Object Properties
    let catalogContainer: CatalogContainer

    @State private var filter: Filter = .missing
    @State private var sortOption: SortOption = .name

    // MARK: - Computed Properties
    //TODO: - Move to view model;
    private var sortedItems: [MasteryItem] {
        let filtered = catalogContainer.masteryItems.filter { filter.matches($0.masteryState) }
        switch sortOption {
        case .name: return filtered.sorted { $0.catalogItemModel.name < $1.catalogItemModel.name }
        case .pointsRemaining: return filtered.sorted { $0.remainingMasteryPoints > $1.remainingMasteryPoints }
        }
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(sortedItems, id: \.self) { item in
                MasteryItemView(viewModel: .init(item: item))
            }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .top) {
            FilterPills(options: Filter.allCases, title: \.title, selection: $filter)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.bg)
        }
        .navigationTitle(catalogContainer.category.displayName.sentenceCased)
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
