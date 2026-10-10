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
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = RankLayout.ringSize

    var body: some View {
        VStack(alignment: .leading, spacing: RankLayout.contentSpacing) {
            HStack {
                Label(Strings.Profile.masteryRankLabel, systemImage: "trophy.fill")
                    .font(.caption.weight(.semibold))
                    .tracking(DashboardLayout.headingTracking)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(DashboardPalette.heroAccent)

            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: RankLayout.ringSpacing))
                : AnyLayout(HStackLayout(alignment: .center, spacing: RankLayout.ringSpacing))

            layout {
                rankRing
                VStack(alignment: .leading, spacing: RankLayout.detailSpacing) {
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
                .frame(height: DashboardLayout.dividerThickness)

            Label(Strings.Mastery.itemsLeft(itemsRemaining), systemImage: "square.stack.3d.up")
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .padding(DashboardLayout.contentPadding)
        .background(DashboardHeroBackground())
        .accessibilityElement(children: .combine)
    }

    private var rankRing: some View {
        VStack {
            Image(systemName: "trophy")
                .font(.title3)
                .foregroundStyle(DashboardPalette.heroAccent)
            Text(Strings.Mastery.rankBadge(progress.rank))
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(Color.labelPrimary)
                .monospacedDigit()
        }
        .background {
            ZStack {
                Circle()
                    .stroke(DashboardPalette.heroAccent.opacity(RankLayout.trackOpacity), lineWidth: RankLayout.trackWidth)
                Circle()
                    .trim(from: 0, to: progress.fraction)
                    .stroke(
                        DashboardPalette.heroAccent.gradient,
                        style: StrokeStyle(lineWidth: RankLayout.progressWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(RankLayout.startAngle))
                    .animation(reduceMotion ? nil : .smooth(duration: RankLayout.animationDuration), value: progress.fraction)
            }
            .padding(RankLayout.ringInset)
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
        VStack(alignment: .leading, spacing: CategoryLayout.contentSpacing) {
            HStack {
                Image(systemName: summary.category.iconName)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(accent)
                    .frame(width: CategoryLayout.iconSize, height: CategoryLayout.iconSize)
                    .background(accent.opacity(CategoryLayout.iconBackgroundOpacity), in: .rect(cornerRadius: CategoryLayout.iconCornerRadius))
                Spacer(minLength: CategoryLayout.minimumSpacerLength)
                Text(fraction, format: .percent.precision(.fractionLength(CategoryLayout.percentageFractionDigits)))
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundStyle(Color.labelSecondary)
            }

            Text(summary.category.displayName.sentenceCased)
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
                .frame(maxWidth: .infinity, minHeight: CategoryLayout.minimumTitleHeight, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: CategoryLayout.countSpacing) {
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
        .padding(CategoryLayout.contentPadding)
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
        VStack(alignment: .leading, spacing: SourceLayout.contentSpacing) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: SourceLayout.accessibilitySpacing) {
                    HStack {
                        sourceIcon
                        Spacer()
                        chevron
                    }
                    summaryText
                }
            } else {
                HStack(spacing: SourceLayout.iconSpacing) {
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
        .padding(SourceLayout.contentPadding)
        .background(Color.surface, in: .rect(cornerRadius: DashboardLayout.cardCornerRadius))
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
        VStack(alignment: .leading, spacing: SourceLayout.detailSpacing) {
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
                Capsule().fill(tint.opacity(CompletionStyle.trackOpacity))
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: geometry.size.width * min(1, max(0, fraction)))
            }
        }
        .frame(height: CompletionStyle.height)
        .animation(reduceMotion ? nil : .smooth(duration: CompletionStyle.animationDuration), value: fraction)
        .accessibilityHidden(true)
    }
}

private struct RankLayout {
    static let ringSize = 88.0
    static let contentSpacing: CGFloat = 10
    static let ringSpacing: CGFloat = 16
    static let detailSpacing: CGFloat = 8
    static let trackOpacity = 0.18
    static let trackWidth: CGFloat = 5
    static let progressWidth: CGFloat = 6
    static let startAngle: Double = -90
    static let animationDuration: TimeInterval = 0.5
    static let ringInset: CGFloat = -20
}

private struct CategoryLayout {
    static let contentSpacing: CGFloat = 10
    static let iconSize: CGFloat = 36
    static let iconBackgroundOpacity = 0.1
    static let iconCornerRadius: CGFloat = 13
    static let minimumSpacerLength: CGFloat = 4
    static let percentageFractionDigits = 0
    static let minimumTitleHeight: CGFloat = 24
    static let countSpacing: CGFloat = 4
    static let contentPadding: CGFloat = 12
}

private struct SourceLayout {
    static let contentSpacing: CGFloat = 16
    static let accessibilitySpacing: CGFloat = 12
    static let iconSpacing: CGFloat = 10
    static let contentPadding: CGFloat = 14
    static let detailSpacing: CGFloat = 4
}

private struct CompletionStyle {
    static let trackOpacity = 0.12
    static let height: CGFloat = 5
    static let animationDuration: TimeInterval = 0.4
}

#Preview("Mastery dashboard") {
    ScrollView {
        VStack(spacing: 16) {
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
        .padding(14)
    }
    .background(Color.bg)
}
