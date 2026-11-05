//
//  WorldStateDashboardComponents.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/09/26.
//

import SwiftUI

struct WorldStateTraderCard: View {
    let trader: VoidTrader

    var body: some View {
        TimelineView(.periodic(from: .now, by: CountdownRefreshInterval.second)) { context in
            let countdown = trader.countdown(at: context.date)
            VoidTraderCardContent(
                character: trader.character,
                location: trader.location,
                countdownLabel: countdown.hasArrived ? Strings.WorldState.baroDepartsIn : Strings.WorldState.baroArrivesIn
            ) {
                LiveCountdownText(
                    date: countdown.targetDate,
                    font: .title2.weight(.semibold),
                    tint: .labelPrimary
                )
            }
        }
        .accessibilityElement(children: .combine)
    }
}
