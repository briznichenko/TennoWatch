//
//  SortieRowView.swift
//  TennoWatch
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
            if !sortie.variants.isEmpty {
                ForEach(sortie.variants, id: \.nodeKey) { variant in
                    SortieVariantRowView(variant: variant)
                }
            } else {
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
}

private struct SortieVariantRowView: View {
    let variant: SortieVariant

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(variant.node)
                Spacer()
                Text(variant.missionType)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Text(variant.modifier)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
            Text(variant.modifierDescription)
                .font(.caption2)
                .foregroundStyle(Color.labelSecondary)
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
