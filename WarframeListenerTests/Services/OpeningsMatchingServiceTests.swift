//
//  OpeningsMatchingServiceTests.swift
//  WarframeListenerTests
//

import Testing
@testable import WarframeListener

@Suite("DefaultOpeningsMatchingService")
struct OpeningsMatchingServiceTests {
    private let sut = DefaultOpeningsMatchingService()

    @Test("Void trader inventory item matches an owned catalog item by uniqueName")
    func voidTraderMatchesByUniqueName() {
        let item = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(uniqueName: "/Lotus/Item"))
        let voidTrader = VoidTrader.stub(
            location: "Larunda Relay",
            inventory: [.init(credits: 50000, ducats: nil, item: "Ignored Display Name", uniqueName: "/Lotus/Item")]
        )
        let worldState = WorldState.stub(voidTrader: voidTrader)

        let openings = sut.timeSensitiveOpenings(for: [item], in: worldState)

        #expect(openings.count == 1)
        #expect(openings.first?.item == item)
        #expect(openings.first?.source == .voidTrader(location: "Larunda Relay", expiry: nil))
    }

    @Test("A completed invasion contributes no openings")
    func completedInvasionIsExcluded() {
        let item = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(name: "Braton Prime"))
        let invasion = Invasion.stub(
            completed: true,
            attacker: .stub(reward: .stub(items: ["Braton Prime"]))
        )
        let worldState = WorldState.stub(invasions: [invasion])

        let openings = sut.timeSensitiveOpenings(for: [item], in: worldState)

        #expect(openings.isEmpty)
    }

    // TODO: - Test that displayName matching is case-insensitive (reward.items vs catalogItemModel.name)
    // TODO: - Test that completion is clamped into 0...100 even when the API reports out-of-range values
    // TODO: - Test that a reward matching an item via both `items` (name) and `countedItems` (uniqueName) only produces one opening, not two
    // TODO: - Test that an empty reward (no items, no countedItems) produces no openings
    // TODO: - Test that invasions and void trader openings are combined (both sources contribute for the same fetch)
}
