//
//  ProfileMissionsListViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import Foundation
import Observation

@Observable
final class ProfileMissionsListViewModel {
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

    var sortOption: SortOption = .completes
    var searchText = ""

    // MARK: - Computed Properties
    var sortedMissions: [MissionStat] {
        let filtered = searchText.isEmpty ? missions : missions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sortOption {
        case .completes: return filtered.sorted { $0.completes > $1.completes }
        case .name: return filtered.sorted { $0.name < $1.name }
        }
    }

    // MARK: - Init
    init(missions: [MissionStat]) {
        self.missions = missions
    }
}
