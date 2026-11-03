//
//  VoidTraderRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct VoidTraderRowView: View {
    let voidTrader: VoidTrader

    var body: some View {
        TimelineView(.periodic(from: .now, by: CountdownRefreshInterval.second)) { context in
            let countdown = voidTrader.countdown(at: context.date)
            VStack(alignment: .leading, spacing: ListLayout.detailSpacing) {
                Text(voidTrader.character)
                    .font(.headline)
                Text(voidTrader.location)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
                HStack(spacing: ListLayout.detailSpacing) {
                    Text(countdown.hasArrived ? Strings.WorldState.baroDepartsIn : Strings.WorldState.baroArrivesIn)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                    LiveCountdownText(date: countdown.targetDate)
                }
            }
        }
    }
}

#Preview {
    List {
        VoidTraderRowView(
            voidTrader: .init(
                activation: .now.addingTimeInterval(-3600),
                expiry: .now.addingTimeInterval(3600),
                id: "voidTrader",
                character: "Baro Ki'Teer",
                completed: nil,
                initialStart: .now,
                inventory: [],
                location: "Relay (Planet)",
                psId: "",
                schedule: []
            )
        )
    }
}
