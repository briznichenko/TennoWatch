//
//  MasteryRankCard.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/03/26.
//

import SwiftUI

struct MasteryRankCard: View {
    let progress: MasteryRankProgress
    let obtainableMasteryMax: Int?
    var itemsRemaining: Int?
    var isWidget = false
    var compact = false
    var profileName: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = RankLayout.ringSize

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : RankLayout.contentSpacing) {
            HStack {
                Label(Strings.Profile.masteryRankLabel, systemImage: "trophy.fill")
                    .font(.caption.weight(.semibold))
                    .tracking(DashboardLayout.headingTracking)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(DashboardPalette.heroAccent)

            let layout = (compact || dynamicTypeSize.isAccessibilitySize)
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: compact ? 6 : RankLayout.ringSpacing))
                : AnyLayout(HStackLayout(alignment: .center, spacing: RankLayout.ringSpacing))

            layout {
                rankRing
                VStack(alignment: .leading, spacing: compact ? 2 : RankLayout.detailSpacing) {
                    Text(Strings.Mastery.totalObtainableXP(obtainableMasteryMax?.formatted() ?? "—"))
                    .font(isWidget ? (compact ? .caption.weight(.semibold) : .headline) : .title2.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    if !compact {
                        Text(Strings.Mastery.earnedXP(progress.currentXP.formatted()))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(Color.labelSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let itemsRemaining {
                Rectangle()
                    .fill(Color.divider)
                    .frame(height: DashboardLayout.dividerThickness)
                Label(Strings.Mastery.itemsLeft(itemsRemaining), systemImage: "square.stack.3d.up")
                    .font(.subheadline)
                    .foregroundStyle(Color.labelSecondary)
            }
            if let profileName {
                Text(profileName)
                    .font(.caption2)
                    .foregroundStyle(Color.labelSecondary)
                    .lineLimit(1)
            }
        }
        .padding(isWidget ? 0 : DashboardLayout.contentPadding)
        .background {
            if !isWidget { DashboardHeroBackground() }
        }
        .accessibilityElement(children: .combine)
    }

    private var rankRing: some View {
        let size = isWidget ? (compact ? 48.0 : 72.0) : ringSize
        
        let progressCircle = ZStack {
            Circle()
                .stroke(DashboardPalette.heroAccent.opacity(RankLayout.trackOpacity),
                        lineWidth: RankLayout.trackWidth / (isWidget ? 2 : 1))
            Circle()
                .trim(from: 0, to: progress.fraction)
                .stroke(
                    DashboardPalette.heroAccent.gradient,
                    style: StrokeStyle(lineWidth: RankLayout.progressWidth / (isWidget ? 2 : 1), lineCap: .round)
                )
                .rotationEffect(.degrees(RankLayout.startAngle))
                .animation(reduceMotion ? nil : .smooth(duration: RankLayout.animationDuration), value: progress.fraction)
        }
        .frame(width: isWidget ? size : nil, height: isWidget ? size : nil)
        
        return ZStack {
            VStack(spacing: compact || isWidget ? 2 : 8) {
                Image(systemName: "trophy")
                    .font(compact ? .caption : .title3)
                    .foregroundStyle(DashboardPalette.heroAccent)
                Text(Strings.Mastery.rankBadge(progress.rank))
                        .font(.system(compact ? .headline : .title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.labelPrimary)
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
            }
            .padding(RankLayout.trackWidth + RankLayout.mrInset)
            progressCircle
        }
        .frame(width: size, height: size)
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
    static let mrInset: CGFloat = 5
}

#Preview {
    MasteryRankCard(progress: .init(rank: 2, currentXP: 2000, xpForCurrentRank: 1000, xpForNextRank: 1000), obtainableMasteryMax: 3_213_138, itemsRemaining: 10, isWidget: false, compact: false, profileName: "Test")
}
