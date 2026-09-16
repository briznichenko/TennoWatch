//
//  OpeningsMatchingServiceTests.swift
//  WarframeListenerTests
//

import Testing
@testable import WarframeListener

@Suite("DefaultOpeningsMatchingService")
struct OpeningsMatchingServiceTests {
    // MARK: - Assemble

    private let sut = DefaultOpeningsMatchingService()

    // MARK: - Teardown

    // MARK: - State Lifecycle

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

    @Test("displayName matching (reward.items vs catalogItemModel.name) is case-insensitive")
    func displayNameMatchingIsCaseInsensitive() {
        let item = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(name: "Braton Prime"))
        let invasion = Invasion.stub(attacker: .stub(reward: .stub(items: ["BRATON PRIME"])))
        let worldState = WorldState.stub(invasions: [invasion])

        let openings = sut.timeSensitiveOpenings(for: [item], in: worldState)

        #expect(openings.count == 1)
        #expect(openings.first?.item == item)
    }

    @Test("completion is clamped into 0...100 even when the API reports out-of-range values")
    func completionIsClamped() {
        let item = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(name: "Braton Prime"))
        let invasion = Invasion.stub(
            completion: 150,
            attacker: .stub(reward: .stub(items: ["Braton Prime"]))
        )
        let worldState = WorldState.stub(invasions: [invasion])

        let openings = sut.timeSensitiveOpenings(for: [item], in: worldState)

        guard case .invasion(_, _, let completion) = openings.first?.source else {
            Issue.record("Expected an .invasion source")
            return
        }
        #expect(completion == 100)
    }

    @Test("A reward matching an item via both items (name) and countedItems (uniqueName) only produces one opening")
    func rewardMatchingBothWaysProducesOneOpening() {
        let item = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(uniqueName: "/Lotus/Item", name: "Braton Prime"))
        let invasion = Invasion.stub(
            attacker: .stub(reward: .stub(
                items: ["Braton Prime"],
                countedItems: [.init(uniqueName: "/Lotus/Item", count: 1, type: "Braton Prime", key: "key")]
            ))
        )
        let worldState = WorldState.stub(invasions: [invasion])

        let openings = sut.timeSensitiveOpenings(for: [item], in: worldState)

        #expect(openings.count == 1)
    }

    @Test("An empty reward (no items, no countedItems) produces no openings")
    func emptyRewardProducesNoOpenings() {
        let item = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(name: "Braton Prime"))
        let invasion = Invasion.stub(attacker: .stub(reward: .stub()))
        let worldState = WorldState.stub(invasions: [invasion])

        let openings = sut.timeSensitiveOpenings(for: [item], in: worldState)

        #expect(openings.isEmpty)
    }

    @Test("Invasions and void trader openings are combined for the same fetch")
    func invasionAndVoidTraderOpeningsAreCombined() {
        let invasionItem = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(name: "Braton Prime"))
        let voidTraderItem = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(uniqueName: "/Lotus/OtherItem"))
        let invasion = Invasion.stub(attacker: .stub(reward: .stub(items: ["Braton Prime"])))
        let voidTrader = VoidTrader.stub(
            location: "Larunda Relay",
            inventory: [.init(credits: 50000, ducats: nil, item: "Ignored", uniqueName: "/Lotus/OtherItem")]
        )
        let worldState = WorldState.stub(invasions: [invasion], voidTrader: voidTrader)

        let openings = sut.timeSensitiveOpenings(for: [invasionItem, voidTraderItem], in: worldState)

        #expect(openings.count == 2)
        #expect(openings.contains { $0.item == invasionItem })
        #expect(openings.contains { $0.item == voidTraderItem })
    }
}
