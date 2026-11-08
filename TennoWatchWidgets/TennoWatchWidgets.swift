//
//  TennoWatchWidgets.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/03/26.
//

import SwiftUI
import WidgetKit

@main
struct TennoWatchWidgets: WidgetBundle {
    var body: some Widget {
        BaroWidget()
        MasteryRankWidget()
    }
}

struct BaroWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshotStore.baroKind, provider: BaroProvider()) { entry in
            BaroWidgetView(entry: entry)
                .containerBackground(for: .widget) { DashboardHeroBackground() }
                .widgetURL(URL(string: "tennowatch://world-state"))
        }
        .configurationDisplayName("Baro Ki’Teer")
        .description("Track the Void Trader’s arrival, departure, and relay.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MasteryRankWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshotStore.masteryKind, provider: MasteryProvider()) { entry in
            MasteryWidgetView(entry: entry)
                .containerBackground(for: .widget) { DashboardHeroBackground() }
                .widgetURL(URL(string: "tennowatch://mastery"))
        }
        .configurationDisplayName("Mastery Rank")
        .description("Your selected profile’s rank and progress toward the next rank.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BaroWidgetView: View {
    let entry: BaroEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                let phase = snapshot.phase(at: entry.date)
                VoidTraderCardContent(
                    character: "Baro Ki’Teer",
                    location: snapshot.location,
                    countdownLabel: countdownLabel(for: phase),
                    isWidget: true,
                    compact: family == .systemSmall
                ) {
                    switch phase {
                    case .upcoming:
                        countdown(until: snapshot.activation)
                    case .visiting:
                        countdown(until: snapshot.expiry)
                    case .departed:
                        Text("Visit ended").font(.headline).foregroundStyle(Color.labelPrimary)
                    case .unavailable:
                        Text("Schedule unavailable").font(.caption).foregroundStyle(Color.labelSecondary)
                    }
                    if entry.isStale {
                        Text("Saved schedule").font(.caption2).foregroundStyle(Color.labelSecondary)
                    }
                }
            } else {
                DashboardHero(
                    title: Strings.WorldState.voidTraderHeader, icon: "person.fill.questionmark",
                    includesBackground: false, compact: family == .systemSmall
                ) {
                    Text("Schedule unavailable").font(.headline).foregroundStyle(Color.labelPrimary)
                    Text("Open TennoWatch or try again later.").font(.caption).foregroundStyle(Color.labelSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func countdownLabel(for phase: BaroSnapshot.Phase) -> String {
        switch phase {
        case .upcoming: Strings.WorldState.baroArrivesIn
        case .visiting: Strings.WorldState.baroDepartsIn
        case .departed, .unavailable: ""
        }
    }

    @ViewBuilder
    private func countdown(until target: Date?) -> some View {
        if let target, target > entry.date {
            Text(timerInterval: entry.date...target, countsDown: true)
                .font(.title2.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color.labelPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }
}

struct MasteryWidgetView: View {
    let entry: MasteryEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                MasteryRankCard(
                    progress: snapshot.progress,
                    obtainableMasteryMax: snapshot.obtainableMasteryMax,
                    isWidget: true,
                    compact: family == .systemSmall,
                    profileName: snapshot.name.isEmpty ? String(localized: "Local profile") : snapshot.name
                )
            } else {
                DashboardHero(
                    title: Strings.Profile.masteryRankLabel, icon: "trophy.fill",
                    includesBackground: false, compact: family == .systemSmall
                ) {
                    Text("Open TennoWatch to load your mastery progress.")
                        .font(.callout).foregroundStyle(Color.labelSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview(as: .systemSmall) {
    BaroWidget()
} timeline: {
    BaroEntry.preview
}

#Preview(as: .systemMedium) {
    MasteryRankWidget()
} timeline: {
    MasteryEntry.preview
}
