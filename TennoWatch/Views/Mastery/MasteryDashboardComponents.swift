//
//  WorldStateGridView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/09/26.
//

import SwiftUI

struct MasteryRankCard: View {
    let progress: MasteryRankProgress
    let itemsRemaining: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = 112.0

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label(Strings.Profile.masteryRankLabel, systemImage: "trophy.fill")
                    .font(.caption.weight(.semibold))
                    .tracking(1)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(DashboardPalette.heroAccent)

            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 20))
                : AnyLayout(HStackLayout(alignment: .center, spacing: 20))

            layout {
                rankRing
                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.Mastery.xpToNextRank(
                        progress.xpToNextRank.formatted(),
                        nextRank: progress.rank + 1
                    ))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    Text("\(progress.currentXP.formatted()) / \(progress.xpForNextRank.formatted())")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Color.labelSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)

            Label(Strings.Mastery.itemsLeft(itemsRemaining), systemImage: "square.stack.3d.up")
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .padding(24)
        .background(DashboardHeroBackground())
        .accessibilityElement(children: .combine)
    }

    private var rankRing: some View {
        ZStack {
            Circle()
                .stroke(DashboardPalette.heroAccent.opacity(0.18), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress.fraction)
                .stroke(
                    DashboardPalette.heroAccent.gradient,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: progress.fraction)
            VStack(spacing: 5) {
                Image(systemName: "trophy")
                    .font(.title3)
                    .foregroundStyle(DashboardPalette.heroAccent)
                Text(Strings.Mastery.rankBadge(progress.rank))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.labelPrimary)
                    .monospacedDigit()
            }
            .padding(12)
        }
        .frame(width: ringSize, height: ringSize)
    }
}

struct MasteryCategoryCard: View {
    let summary: CatalogContainerSummary

    @Environment(\.colorScheme) private var colorScheme

    private var fraction: Double {
        guard summary.itemsCount > 0 else { return 0 }
        return min(1, max(0, Double(summary.masteredItemsCount) / Double(summary.itemsCount)))
    }

    private var accent: Color {
        DashboardPalette.accent(in: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: summary.category.iconName)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.1), in: .rect(cornerRadius: 13))
                Spacer(minLength: 4)
                Text(fraction, format: .percent.precision(.fractionLength(0)))
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundStyle(Color.labelSecondary)
            }

            Text(summary.category.displayName.sentenceCased)
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(summary.masteredItemsCount, format: .number)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                Text("/ \(summary.itemsCount.formatted())")
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            .monospacedDigit()

            MasteryCompletionBar(fraction: fraction, tint: accent)
        }
        .padding(16)
        .background(DashboardCardBackground())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary.category.displayName.sentenceCased)
        .accessibilityValue(summary.countText)
    }
}

struct MasterySourceCard: View {
    let summary: MasteryCategorySummary

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var icon: String {
        switch MasterySourceType(rawValue: summary.name) {
        case .nodes: "globe.europe.africa"
        case .intrinsics: "sparkles"
        case .junctions: "point.3.connected.trianglepath.dotted"
        case nil: "hexagon"
        }
    }

    var body: some View {
        let accent = DashboardPalette.accent(in: colorScheme)
        VStack(alignment: .leading, spacing: 16) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        sourceIcon
                        Spacer()
                        chevron
                    }
                    summaryText
                }
            } else {
                HStack(spacing: 14) {
                    sourceIcon
                    summaryText
                    Spacer()
                    chevron
                }
            }
            MasteryCompletionBar(
                fraction: summary.itemsCount > 0
                    ? Double(summary.masteredItemsCount) / Double(summary.itemsCount)
                    : 0,
                tint: accent
            )
        }
        .padding(20)
        .background(Color.surface, in: .rect(cornerRadius: 22))
        .accessibilityElement(children: .combine)
    }

    private var sourceIcon: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundStyle(DashboardPalette.accent(in: colorScheme))
            .accessibilityHidden(true)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.labelSecondary)
            .accessibilityHidden(true)
    }

    private var summaryText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summary.name.sentenceCased)
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
            Text(summary.countText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(Color.labelSecondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct MasteryCompletionBar: View {
    let fraction: Double
    let tint: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(0.12))
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: geometry.size.width * min(1, max(0, fraction)))
            }
        }
        .frame(height: 5)
        .animation(reduceMotion ? nil : .smooth(duration: 0.4), value: fraction)
        .accessibilityHidden(true)
    }
}

#Preview("Mastery dashboard") {
    ScrollView {
        VStack(spacing: 20) {
            MasteryRankCard(
                progress: .init(rank: 18, currentXP: 842_500, xpForCurrentRank: 810_000, xpForNextRank: 902_500),
                itemsRemaining: 286
            )
            HStack(spacing: 12) {
                MasteryCategoryCard(summary: .init(
                    category: .suits, itemsCount: 112, masteredItemsCount: 76,
                    obtainableItemsCount: 110, obtainableRemainingCount: 34, earnedMasteryPoints: 456_000
                ))
                MasteryCategoryCard(summary: .init(
                    category: .longGuns, itemsCount: 184, masteredItemsCount: 92,
                    obtainableItemsCount: 180, obtainableRemainingCount: 88, earnedMasteryPoints: 276_000
                ))
            }
        }
        .padding(20)
    }
    .background(Color.bg)
}
