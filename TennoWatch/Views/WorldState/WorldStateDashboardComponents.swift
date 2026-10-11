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
        TimelineView(.periodic(from: .now, by: CountdownRefreshInterval.minute)) { context in
            let hasArrived = trader.activation.map { $0 <= context.date } ?? true
            DashboardHero(title: Strings.WorldState.voidTraderHeader, icon: "person.fill.questionmark", showsDisclosure: true) {
                VStack(alignment: .leading, spacing: Layout.contentSpacing) {
                    Text(trader.character)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(Color.labelPrimary)
                    Label(trader.location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(Color.labelSecondary)
                }
                VStack(alignment: .leading, spacing: Layout.detailSpacing) {
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

private struct Layout {
    static let contentSpacing: CGFloat = 8
    static let detailSpacing: CGFloat = 6
}
