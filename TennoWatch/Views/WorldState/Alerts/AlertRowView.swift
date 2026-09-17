//
//  AlertRowView.swift
//  TennoWatch
//

import SwiftUI

struct AlertRowView: View {
    let alert: Alert

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(alert.mission.node)
                    .font(.headline)
                Spacer()
                LiveCountdownText(date: alert.expiry)
            }
            Text(alert.mission.type)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
            if !alert.rewardTypes.isEmpty {
                Text(alert.rewardTypes.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        AlertRowView(
            alert: .init(
                activation: .now,
                expiry: .now.addingTimeInterval(3600),
                id: "alert",
                mission: .init(
                    advancedSpawners: [],
                    archwingRequired: false,
                    consumeRequiredItems: nil,
                    description: nil,
                    enemySpec: nil,
                    exclusiveWeapon: nil,
                    faction: "Grineer",
                    factionKey: "grineer",
                    goalTag: nil,
                    isSharkwing: false,
                    leadersAlwaysAllowed: nil,
                    levelAuras: [],
                    levelOverride: nil,
                    maxEnemyLevel: nil,
                    maxWaveNum: nil,
                    minEnemyLevel: nil,
                    nightmare: false,
                    node: "Node (Planet)",
                    nodeKey: "node",
                    requiredItems: [],
                    reward: nil,
                    target: nil,
                    type: "Exterminate",
                    typeKey: "exterminate"
                ),
                rewardTypes: ["Credits", "Endo"],
                tag: nil
            )
        )
    }
}
