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

        func matches(_ state: MasteryState) -> Bool {
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
    let catalogContainer: CatalogContainerModel
    var itemSnapshots: [String: MasterySummary.ItemSnapshot] = [:]

    @State private var filter: Filter = .missing
    @State private var sortOption: SortOption = .name

    // MARK: - Computed Properties
    //TODO: - Move to view model;
    private var sortedItems: [MasteryItemDataModel] {
        let filtered = catalogContainer.masteryItems.filter { filter.matches(masteryState(for: $0)) }
        switch sortOption {
        case .name: return filtered.sorted { $0.catalogItem.name < $1.catalogItem.name }
        case .pointsRemaining: return filtered.sorted { remainingMasteryPoints(for: $0) > remainingMasteryPoints(for: $1) }
        }
    }

    private func masteryState(for item: MasteryItemDataModel) -> MasteryState {
        itemSnapshots[item.catalogItem.uniqueName]?.masteryState ?? item.masteryState
    }

    private func remainingMasteryPoints(for item: MasteryItemDataModel) -> Int {
        itemSnapshots[item.catalogItem.uniqueName]?.remainingMasteryPoints ?? item.remainingMasteryPoints
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(sortedItems) { item in
                MasteryItemView(item: item, snapshot: itemSnapshots[item.catalogItem.uniqueName])
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
