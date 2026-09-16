//
//  ProfileItemsListViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import Foundation
import Observation

@Observable
final class ProfileItemsListViewModel {
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

    var sortOption: SortOption = .kills
    var searchText = ""

    // MARK: - Computed Properties
    var sortedItems: [ProfileItemStat] {
        let filtered = searchText.isEmpty ? items : items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sortOption {
        case .kills: return filtered.sorted { $0.kills > $1.kills }
        case .xp: return filtered.sorted { $0.xp > $1.xp }
        case .name: return filtered.sorted { $0.name < $1.name }
        }
    }

    // MARK: - Init
    init(items: [ProfileItemStat]) {
        self.items = items
    }
}
