//
//  VoidTraderRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct VoidTraderRowView: View {
    let voidTrader: VoidTrader

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(voidTrader.character)
                .font(.headline)
            Text(voidTrader.location)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
    }
}

#Preview {
    List {
        VoidTraderRowView(
            voidTrader: .init(
                activation: .now,
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
