//
//  ProfileItemsListView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileItemsListView: View {
    enum SortOption: String, CaseIterable, Identifiable, Hashable {
        case kills, xp, name

        var id: String { rawValue }
        var title: String {
            switch self {
            case .kills: Strings.Profile.sortOptionKills
            case .xp: Strings.Profile.sortOptionXP
            case .name: Strings.Profile.sortOptionName
            }
        }
    }

    // MARK: - Object Properties
    let items: [ProfileItemStat]

    @State private var sortOption: SortOption = .kills
    @State private var searchText = ""

    // MARK: - Computed Properties
    // TODO: - Move to view model;
    private var sortedItems: [ProfileItemStat] {
        let filtered = searchText.isEmpty ? items : items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sortOption {
        case .kills: return filtered.sorted { $0.kills > $1.kills }
        case .xp: return filtered.sorted { $0.xp > $1.xp }
        case .name: return filtered.sorted { $0.name < $1.name }
        }
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(sortedItems) { item in
                ProfileItemStatRowView(item: item)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Profile.searchPlaceholder)
        .navigationTitle(Strings.Profile.itemsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(Strings.Profile.sortBy, selection: $sortOption) {
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
