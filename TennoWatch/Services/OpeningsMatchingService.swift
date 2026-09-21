//
//  OpeningsMatchingService.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Foundation

protocol OpeningsMatchingService {
    func timeSensitiveOpenings(for items: [MasteryItem], in worldState: WorldState) -> [TimeSensitiveOpening]
}

struct DefaultOpeningsMatchingService: OpeningsMatchingService {
    // MARK: - Functions
    func timeSensitiveOpenings(for items: [MasteryItem], in worldState: WorldState) -> [TimeSensitiveOpening] {
        invasionOpenings(for: items, invasions: worldState.invasions)
            + voidTraderOpenings(for: items, voidTrader: worldState.voidTrader)
            + vaultTraderOpenings(for: items, vaultTrader: worldState.vaultTrader)
    }

    // MARK: - Helper Functions
    private func invasionOpenings(for items: [MasteryItem], invasions: [Invasion]) -> [TimeSensitiveOpening] {
        invasions.filter { !$0.completed }.flatMap { invasion in
            [invasion.attacker, invasion.defender].flatMap { faction -> [TimeSensitiveOpening] in
                guard let reward = faction.reward else { return [] }
                let completion = min(100, max(0, invasion.completion))
                return matchingItems(in: reward, from: items).map {
                    TimeSensitiveOpening(
                        item: $0,
                        source: .invasion(node: invasion.node, faction: faction.faction, completion: completion)
                    )
                }
            }
        }
    }

    private func voidTraderOpenings(for items: [MasteryItem], voidTrader: VoidTrader) -> [TimeSensitiveOpening] {
        voidTrader.inventory.flatMap { invItem in
            matchingItems(uniqueName: invItem.uniqueName, displayName: invItem.item, in: items).map {
                TimeSensitiveOpening(
                    item: $0,
                    source: .voidTrader(location: voidTrader.location, expiry: voidTrader.expiry)
                )
            }
        }
    }

    private func vaultTraderOpenings(for items: [MasteryItem], vaultTrader: VoidTrader) -> [TimeSensitiveOpening] {
        vaultTrader.inventory.flatMap { invItem in
            matchingItems(uniqueName: invItem.uniqueName, displayName: invItem.item, in: items).map {
                TimeSensitiveOpening(
                    item: $0,
                    source: .vaultTrader(location: vaultTrader.location, expiry: vaultTrader.expiry)
                )
            }
        }
    }

    private func matchingItems(in reward: Reward, from items: [MasteryItem]) -> [MasteryItem] {
        var matched: [String: MasteryItem] = [:]
        for name in reward.items {
            for item in matchingItems(uniqueName: nil, displayName: name, in: items) {
                matched[item.catalogItemModel.uniqueName] = item
            }
        }
        for countedItem in reward.countedItems {
            for item in matchingItems(uniqueName: countedItem.uniqueName, displayName: countedItem.type, in: items) {
                matched[item.catalogItemModel.uniqueName] = item
            }
        }
        return Array(matched.values)
    }

    private func matchingItems(uniqueName: String?, displayName: String, in items: [MasteryItem]) -> [MasteryItem] {
        if let uniqueName, let exact = items.first(where: { $0.catalogItemModel.uniqueName == uniqueName }) {
            return [exact]
        }
        guard !displayName.isEmpty else { return [] }
        return items.filter { displayName.localizedCaseInsensitiveContains($0.catalogItemModel.name) }
    }
}
