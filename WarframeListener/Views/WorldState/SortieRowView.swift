//
//  SortieRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct SortieRowView: View {
    let sortie: Sortie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(sortie.boss)
                .font(.headline)
            ForEach(sortie.missions, id: \.nodeKey) { mission in
                HStack {
                    Text(mission.node)
                    Spacer()
                    Text(mission.type)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
        }
    }
}

#Preview {
    List {
        SortieRowView(
            sortie: .init(
                activation: .now,
                expiry: .now.addingTimeInterval(3600),
                id: "sortie",
                boss: "Sortie Boss",
                faction: "Grineer",
                factionKey: "grineer",
                missions: [
                    .init(
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
                    )
                ],
                rewardPool: "",
                variants: []
            )
        )
    }
}
