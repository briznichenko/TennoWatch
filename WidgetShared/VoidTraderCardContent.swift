//
//  VoidTraderCardContent.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/03/26.
//

import SwiftUI

struct VoidTraderCardContent<Countdown: View>: View {
    let character: String
    let location: String
    let countdownLabel: String
    var isWidget = false
    var compact = false
    @ViewBuilder var countdown: Countdown

    var body: some View {
        DashboardHero(
            title: Strings.WorldState.voidTraderHeader,
            icon: "person.fill.questionmark",
            showsDisclosure: true,
            includesBackground: !isWidget,
            compact: compact || isWidget
        ) {
            VStack(alignment: .leading, spacing: compact ? 4 : 8) {
                Text(character)
                    .font(compact ? .headline : (isWidget ? .title2.weight(.semibold) : .title.weight(.semibold)))
                    .foregroundStyle(Color.labelPrimary)
                    .lineLimit(isWidget ? 1 : nil)
                    .minimumScaleFactor(0.8)
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(compact ? .caption2 : (isWidget ? .caption : .subheadline))
                    .foregroundStyle(Color.labelSecondary)
                    .lineLimit(isWidget ? 2 : nil)
            }
            VStack(alignment: .leading, spacing: isWidget ? 2 : 6) {
                if !countdownLabel.isEmpty {
                    Text(countdownLabel)
                        .font(.caption)
                        .foregroundStyle(DashboardPalette.heroAccent)
                }
                countdown
            }
        }
        .accessibilityElement(children: .combine)
    }
}
