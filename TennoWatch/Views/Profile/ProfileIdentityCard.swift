//
//  ProfileIdentityCard.swift
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
    let isSyncing: Bool
    let onSync: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        DashboardHero(
            title: isLocal ? Strings.Profile.manualProfileDescription : Strings.Settings.accountLabel,
            icon: isLocal ? "pencil.circle" : "person.crop.circle"
        ) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: Layout.accessibilitySpacing))
                : AnyLayout(HStackLayout(alignment: .top, spacing: Layout.contentSpacing))
            layout {
                VStack(alignment: .leading, spacing: Layout.identitySpacing) {
                    Text(displayName)
                        .font(.title2.weight(.semibold))
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
                if !isLocal {
                    HStack(spacing: Layout.identitySpacing) {
                        Image(systemName: "trophy.fill")
                        Text(Strings.Mastery.rankBadge(rank))
                    }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DashboardPalette.heroAccent)
                        .padding(.horizontal, Layout.badgeHorizontalPadding)
                        .padding(.vertical, Layout.badgeVerticalPadding)
                        .background(DashboardPalette.heroAccent.opacity(Layout.badgeOpacity), in: .capsule)
                        .fixedSize()
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(verbatim: "\(Strings.Profile.masteryRankLabel), \(Strings.Mastery.rankBadge(rank))"))
                }
            }
            if !isLocal {
                Rectangle()
                    .fill(Color.divider)
                    .frame(height: DashboardLayout.dividerThickness)
                layout {
                    DashboardMetric(value: missionsCompleted.formatted(), title: Strings.Profile.missionsCompletedLabel, valueFont: .title2.weight(.semibold))
                    DashboardMetric(value: totalKills.formatted(), title: Strings.Profile.totalKillsLabel, valueFont: .title2.weight(.semibold))
                }
                Button(action: onSync) {
                    Group {
                        if dynamicTypeSize.isAccessibilitySize {
                            Text(Strings.Profile.syncButton)
                        } else {
                            Label(Strings.Profile.syncButton, systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil)
                }
                .buttonStyle(AppGlassButtonStyle())
                .controlSize(.small)
                .tint(DashboardPalette.heroAccent)
                .disabled(isSyncing)
            }
        }
    }
}

private struct Layout {
    static let accessibilitySpacing: CGFloat = 12
    static let contentSpacing: CGFloat = 16
    static let identitySpacing: CGFloat = 6
    static let badgeHorizontalPadding: CGFloat = 12
    static let badgeVerticalPadding: CGFloat = 8
    static let badgeOpacity = 0.12
}
