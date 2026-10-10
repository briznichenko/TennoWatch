//
//  WorldStateGridView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/09/26.
//

import SwiftUI

struct ProfileIdentityCard: View {
    let displayName: String
    let accountID: String
    let isLocal: Bool
    let rank: Int
    let missionsCompleted: Int
    let totalKills: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        DashboardHero(
            title: isLocal ? Strings.Profile.manualProfileDescription : Strings.Settings.accountLabel,
            icon: isLocal ? "pencil.circle" : "person.crop.circle"
        ) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 16))
            layout {
                VStack(alignment: .leading, spacing: 6) {
                    Text(displayName)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(Color.labelPrimary)
                    if !isLocal && !accountID.isEmpty {
                        Text(accountID)
                            .font(.caption.monospaced())
                            .foregroundStyle(Color.labelSecondary)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                    Text(Strings.Mastery.rankBadge(rank))
                }
                    .font(.headline)
                    .foregroundStyle(DashboardPalette.heroAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DashboardPalette.heroAccent.opacity(0.12), in: .capsule)
                    .fixedSize()
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(verbatim: "\(Strings.Profile.masteryRankLabel), \(Strings.Mastery.rankBadge(rank))"))
            }
            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)
            layout {
                DashboardMetric(value: missionsCompleted.formatted(), title: Strings.Profile.missionsCompletedLabel)
                DashboardMetric(value: totalKills.formatted(), title: Strings.Profile.totalKillsLabel)
            }
        }
    }
}
