//
//  FissureRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct FissureRowView: View {
    let fissure: Fissure

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(fissure.node)
                Text("\(fissure.tier) · \(fissure.missionType)")
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
            if fissure.isStorm {
                Image(systemName: "wind")
                    .foregroundStyle(Color.labelSecondary)
            }
        }
    }
}

#Preview {
    List {
        FissureRowView(
            fissure: .init(
                activation: .now,
                expiry: .now.addingTimeInterval(3600),
                id: "fissure",
                enemy: "Grineer",
                enemyKey: "grineer",
                isHard: false,
                isStorm: false,
                missionType: "Capture",
                missionTypeKey: "capture",
                node: "Node (Planet)",
                nodeKey: "node",
                tier: "Lith"
            )
        )
    }
}
