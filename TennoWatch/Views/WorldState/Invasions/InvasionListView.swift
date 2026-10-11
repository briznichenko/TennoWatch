//
//  InvasionListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct InvasionListView: View {
    let groups: [InvasionPlanetGroup]

    @State private var searchText = ""

    private var filteredGroups: [InvasionPlanetGroup] {
        groups.compactMap { group in
            let matches = group.invasions.filter { invasion in
                let rewards = [invasion.attacker.reward, invasion.defender.reward].compactMap { $0 }
                let names = rewards.flatMap { $0.items + $0.countedItems.map(\.type) }
                return ([invasion.node, invasion.nodeKey, group.planet] + names)
                    .joined(separator: " ").matchesSearch(searchText)
            }
            return matches.isEmpty ? nil : InvasionPlanetGroup(planet: group.planet, invasions: matches)
        }
    }

    var body: some View {
        ThemedList {
            ForEach(filteredGroups) { group in
                Section {
                    ForEach(group.invasions) { invasion in
                        InvasionView(invasion: invasion)
                    }
                } header: {
                    SectionHeaderLabel(group.planet)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchNodes)
        .navigationTitle(Strings.WorldState.invasionsHeader)
        .inlineNavigationTitle()
    }
}
