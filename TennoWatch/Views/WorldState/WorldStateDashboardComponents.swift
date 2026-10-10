//
//  WorldStateGridView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/09/26.
//

import SwiftUI

struct WorldStateTraderCard: View {
    let trader: VoidTrader

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let hasArrived = trader.activation.map { $0 <= context.date } ?? true
            DashboardHero(title: Strings.WorldState.voidTraderHeader, icon: "person.fill.questionmark", showsDisclosure: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(trader.character)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(Color.labelPrimary)
                    Label(trader.location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(Color.labelSecondary)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(hasArrived ? Strings.WorldState.baroDepartsIn : Strings.WorldState.baroArrivesIn)
                        .font(.caption)
                        .foregroundStyle(DashboardPalette.heroAccent)
                    LiveCountdownText(
                        date: hasArrived ? trader.expiry : trader.activation,
                        font: .title2.weight(.semibold),
                        tint: .labelPrimary
                    )
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct WorldStateCycleCard: View {
    let cycle: WorldCycleDisplay

    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .body) private var width = 148.0

    private var icon: String {
        switch cycle.id {
        case "cetus", "earth": cycle.state == Strings.WorldState.cycleDay ? "sun.max.fill" : "moon.stars.fill"
        case "vallis": cycle.state == Strings.WorldState.cycleWarm ? "sun.max.fill" : "snowflake"
        case "cambion": "sun.haze.fill"
        default: "sparkles"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(cycle.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.labelSecondary)
                Spacer(minLength: 4)
                Image(systemName: icon)
                    .foregroundStyle(DashboardPalette.accent(in: colorScheme))
                    .accessibilityHidden(true)
            }
            Text(cycle.state)
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
            if cycle.expiry != nil {
                LiveCountdownText(date: cycle.expiry)
            } else if !cycle.timeLeft.isEmpty {
                Text(cycle.timeLeft)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: min(width, 260), alignment: .leading)
        .padding(16)
        .background(DashboardCardBackground(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}
