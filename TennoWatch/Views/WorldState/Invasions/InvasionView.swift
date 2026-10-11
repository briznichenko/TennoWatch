//
//  InvasionView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct InvasionView: View {
    // MARK: - Object Properties
    let invasion: Invasion

    // MARK: - Computed Properties
    private var nodeName: String { invasion.node.nodeNameAndPlanet.name }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.contentSpacing) {
            Text(nodeName)
                .font(.subheadline.weight(.medium))
            HStack {
                factionView(invasion.attacker, isAttacker: true)
                Spacer()
                factionView(invasion.defender, isAttacker: false)
            }
            let requiredRuns = 1.0 / Double(invasion.requiredRuns)
            let current = Double(abs(invasion.count)) * requiredRuns
            ProgressView(value: current > 1 ? 1 : current)
        }
        .padding(.vertical, Layout.verticalPadding)
    }

    // MARK: - Helper Functions
    private func factionView(_ faction: Faction, isAttacker: Bool) -> some View {
        VStack(alignment: isAttacker ? .leading : .trailing, spacing: Layout.factionSpacing) {
            Text(faction.faction)
                .font(.caption)
                .foregroundStyle(isAttacker ? .red : .green)
            if let reward = faction.reward?.items.first {
                Text(reward)
                    .font(.caption2)
                    .foregroundStyle(Color.labelSecondary)
            }
            if let countedReward = faction.reward?.countedItems.first {
                Text("\(countedReward.key), \(countedReward.count)")
                    .font(.caption2)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
    }
}

private struct Layout {
    static let contentSpacing: CGFloat = 3
    static let factionSpacing: CGFloat = 1
    static let verticalPadding: CGFloat = 2
}

#Preview {
    InvasionView(
        invasion:
                .init(
                    id: "",
                    activation: .now,
                    node: "Node",
                    nodeKey: "nodeKey",
                    desc: "adadad",
                    attacker:
                            .init(
                                reward:
                                        .init(
                                            items: ["Item"],
                                            countedItems: [.init(
                                                count: 1,
                                                type: "Type",
                                                key: "Type"
                                            )],
                                            credits: 100,
                                            thumbnail: .none,
                                            color: 0
                                        ),
                                faction: "Attacker",
                                factionKey: ""
                            ),
                    defender:
                            .init(
                                reward:
                                        .init(
                                            items: ["Item"],
                                            countedItems: [.init(
                                                count: 1,
                                                type: "Type",
                                                key: "Type"
                                            )],
                                            credits: 100,
                                            thumbnail: .none,
                                            color: 0
                                        ),
                                faction: "Defender",
                                factionKey: ""
                            ),
                    vsInfestation: false,
                    count: 9,
                    requiredRuns: 10,
                    completion: 0,
                    completed: false,
                    rewardTypes: []
                ))
}
