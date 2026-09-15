//
//  ProfileMissionsListView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileMissionsListView: View {
    enum SortOption: String, CaseIterable, Identifiable, Hashable {
        case completes, name

        var id: String { rawValue }
        var title: String {
            switch self {
            case .completes: Strings.Profile.sortOptionCompletes
            case .name: Strings.Profile.sortOptionName
            }
        }
    }

    // MARK: - Object Properties
    let missions: [MissionStat]

    @State private var sortOption: SortOption = .completes
    @State private var searchText = ""

    // MARK: - Computed Properties
    // TODO: - Move to view model;
    private var sortedMissions: [MissionStat] {
        let filtered = searchText.isEmpty ? missions : missions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sortOption {
        case .completes: return filtered.sorted { $0.completes > $1.completes }
        case .name: return filtered.sorted { $0.name < $1.name }
        }
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(sortedMissions) { mission in
                ProfileMissionRowView(mission: mission)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Profile.searchPlaceholder)
        .navigationTitle(Strings.Profile.missionsTitle)
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
