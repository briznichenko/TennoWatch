//
//  VoidTraderRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct VoidTraderRowView: View {
    let voidTrader: VoidTrader

    // MARK: - Computed Properties
    private var hasArrived: Bool {
        guard let activation = voidTrader.activation else { return true }
        return activation <= .now
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(voidTrader.character)
                .font(.headline)
            Text(voidTrader.location)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
            HStack(spacing: 4) {
                Text(hasArrived ? Strings.WorldState.baroDepartsIn : Strings.WorldState.baroArrivesIn)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
                LiveCountdownText(date: hasArrived ? voidTrader.expiry : voidTrader.activation)
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
