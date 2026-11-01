//
//  FissureListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct FissureListView: View {
    let groups: [FissureStarChartGroup]

    @State private var searchText = ""

    private var filteredGroups: [FissureStarChartGroup] {
        groups.compactMap { group in
            let tiers = group.tiers.compactMap { tier -> FissureTierGroup? in
                let matches = tier.fissures.filter {
                    [$0.node, $0.nodeKey, $0.missionType, tier.tier, group.chart.title].joined(separator: " ").matchesSearch(searchText)
                }
                return matches.isEmpty ? nil : FissureTierGroup(tier: tier.tier, fissures: matches)
            }
            return tiers.isEmpty ? nil : FissureStarChartGroup(chart: group.chart, tiers: tiers)
        }
    }

    var body: some View {
        ThemedList {
            ForEach(filteredGroups) { group in
                Section {
                    ForEach(group.tiers) { tier in
                        Text(tier.tier)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.labelSecondary)
                            .listRowSeparator(.hidden)
                        ForEach(tier.fissures, id: \.nodeKey) { fissure in
                            FissureRowView(fissure: fissure)
                        }
                    }
                } header: {
                    SectionHeaderLabel(group.chart.title)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchNodes)
        .navigationTitle(Strings.WorldState.fissuresHeader)
        .inlineNavigationTitle()
    }
}
