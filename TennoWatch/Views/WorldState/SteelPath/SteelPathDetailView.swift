//
//  SteelPathDetailView.swift
//  TennoWatch
//

import SwiftUI

struct SteelPathDetailView: View {
    let steelPath: SteelPathOfferings

    var body: some View {
        List {
            if let currentReward = steelPath.currentReward {
                Section {
                    SteelPathRewardRowView(reward: currentReward)
                } header: {
                    SectionHeaderLabel(Strings.WorldState.currentRewardHeader)
                }
            }
            Section {
                ForEach(steelPath.rotation, id: \.name) { reward in
                    SteelPathRewardRowView(reward: reward)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.rotationHeader)
            }
            Section {
                ForEach(steelPath.evergreens, id: \.name) { reward in
                    SteelPathRewardRowView(reward: reward)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.evergreensHeader)
            }
            Section {
                incursionRow
            } header: {
                SectionHeaderLabel(Strings.WorldState.incursionHeader)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.steelPathHeader)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews
    @ViewBuilder
    private var incursionRow: some View {
        if let expiry = steelPath.incursions?.expiry {
            LiveCountdownText(date: expiry)
        } else {
            Text(Strings.WorldState.noActiveIncursion)
                .foregroundStyle(Color.labelSecondary)
        }
    }
}
