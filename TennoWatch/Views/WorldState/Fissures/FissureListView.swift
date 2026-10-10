//
//  FissureListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct FissureListView: View {
    let groups: [FissureTierGroup]

    @State private var searchText = ""

    private var filteredGroups: [FissureTierGroup] {
        groups.compactMap { group in
            let matches = group.fissures.filter {
                [$0.node, $0.nodeKey, $0.missionType, group.tier].joined(separator: " ").matchesSearch(searchText)
            }
            return matches.isEmpty ? nil : FissureTierGroup(tier: group.tier, fissures: matches)
        }
    }

    var body: some View {
        ThemedList {
            ForEach(filteredGroups) { group in
                Section {
                    ForEach(group.fissures, id: \.nodeKey) { fissure in
                        FissureRowView(fissure: fissure)
                    }
                } header: {
                    SectionHeaderLabel(group.tier)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchNodes)
        .navigationTitle(Strings.WorldState.fissuresHeader)
        .inlineNavigationTitle()
    }
}
