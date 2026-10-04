//
//  ProfileMissionsListViewModel.swift
//  TennoWatch
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
        let filtered = missions.filter { $0.name.matchesSearch(searchText) || $0.tag.matchesSearch(searchText) }
        switch sortOption {
        case .completes: return filtered.sorted { $0.completes > $1.completes }
        case .name: return filtered.sorted { $0.name < $1.name }
        }
    }

    var starChartSections: [StarChartSection<MissionStat>] {
        StarChartMode.sections(from: sortedMissions, mode: \.starChartMode)
    }

    // MARK: - Init
    init(missions: [MissionStat]) {
        self.missions = missions
    }
}
