//
//  WorldStateEventsCard.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/18/26.
//

import SwiftUI

struct WorldStateEventsCard: View {
    let events: [WorldEvent]

    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                ForEach(events, id: \.tag) { event in
                    if event.tag != events.first?.tag {
                        Divider().overlay(Color.divider)
                    }
                    eventRow(event)
                }
            }
            .padding(.top, Layout.rowSpacing)
        } label: {
            HStack {
                DashboardSectionHeader(title: Strings.WorldState.eventsHeader, icon: "sparkles")
                Spacer()
                Text(events.count, format: .number)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                    .monospacedDigit()
            }
        }
        .tint(accent)
        .padding(DashboardLayout.contentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DashboardCardBackground())
    }

    private var accent: Color { DashboardPalette.accent(in: colorScheme) }

    private func eventRow(_ event: WorldEvent) -> some View {
        VStack(alignment: .leading, spacing: Layout.detailSpacing) {
            Text(event.description)
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let node = event.node, !node.isEmpty {
                Label(node, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(Color.labelSecondary)
            }

            if event.expiry != nil {
                HStack(spacing: Layout.detailSpacing) {
                    Text(Strings.WorldState.expiresIn)
                    LiveCountdownText(date: event.expiry, showsSeconds: false)
                }
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
                .accessibilityElement(children: .combine)
            }

            if let progress = event.communityProgress {
                ProgressView(value: progress) {
                    Text(Strings.WorldState.communityProgress)
                } currentValueLabel: {
                    Text(progress, format: .percent.precision(.fractionLength(0...1)))
                        .monospacedDigit()
                }
                .progressViewStyle(EventProgressStyle(tint: accent))
                .font(.caption)
                .foregroundStyle(accent)
                .tint(accent)
            }
        }
    }
}

private struct EventProgressStyle: ProgressViewStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: Layout.detailSpacing) {
            HStack {
                configuration.label
                Spacer()
                configuration.currentValueLabel
            }
            GeometryReader { geometry in
                Capsule()
                    .fill(tint.opacity(Layout.trackOpacity))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(tint)
                            .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0))
                    }
            }
            .frame(height: Layout.progressHeight)
        }
    }
}

private struct Layout {
    static let rowSpacing: CGFloat = 14
    static let detailSpacing: CGFloat = 6
    static let progressHeight: CGFloat = 6
    static let trackOpacity = 0.15
}
