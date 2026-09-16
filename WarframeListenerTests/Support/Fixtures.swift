//
//  Fixtures.swift
//  WarframeListenerTests
//

import Foundation
@testable import WarframeListener

extension WorldState {
    static func stub(
        invasions: [Invasion] = [],
        voidTrader: VoidTrader = .stub(),
        fissures: [Fissure] = []
    ) -> WorldState {
        WorldState(
            alerts: [],
            arbitration: nil,
            archimedeas: [],
            archonHunt: .stub(),
            buildLabel: "",
            calendar: .stub(),
            cambionCycle: .stub(),
            cetusCycle: .stub(),
            clanWeeklyInitiative: nil,
            conclaveChallenges: [],
            constructionProgress: .stub(),
            dailyDeals: [],
            darkSectors: [],
            duviriCycle: .stub(),
            earthCycle: .stub(),
            events: [],
            fissures: fissures,
            flashSales: [],
            globalUpgrades: [],
            invasions: invasions,
            kinepage: .stub(),
            kuva: nil,
            news: [],
            nightwave: nil,
            persistentEnemies: [],
            sentientOutposts: .stub(),
            simaris: .stub(),
            sortie: .stub(),
            steelPath: .stub(),
            syndicateMissions: [],
            timestamp: .now,
            vallisCycle: .stub(),
            vaultTrader: .stub(),
            voidTrader: voidTrader,
            voidTraders: [],
            weeklyChallenges: nil,
            zarimanCycle: .stub()
        )
    }
}

extension Sortie {
    static func stub() -> Sortie {
        .init(activation: nil, expiry: nil, id: nil, boss: "", faction: "", factionKey: "", missions: [], rewardPool: "", variants: [])
    }
}

extension GameCalendar {
    static func stub() -> GameCalendar {
        .init(activation: nil, expiry: nil, id: nil, requirements: [], season: "", version: 0, yearIteration: 0)
    }
}

extension CambionCycle {
    static func stub() -> CambionCycle {
        .init(activation: nil, expiry: nil, id: nil, state: "", timeLeft: "")
    }
}

extension CetusCycle {
    static func stub() -> CetusCycle {
        .init(activation: nil, expiry: nil, id: nil, isCetus: false, isDay: true, state: "", timeLeft: "")
    }
}

extension ConstructionProgress {
    static func stub() -> ConstructionProgress {
        .init(activation: nil, expiry: nil, id: nil, fomorianProgress: "", razorbackProgress: "", unknownProgress: "")
    }
}

extension DuviriCycle {
    static func stub() -> DuviriCycle {
        .init(activation: nil, expiry: nil, id: nil, choices: [], state: "")
    }
}

extension EarthCycle {
    static func stub() -> EarthCycle {
        .init(activation: nil, expiry: nil, id: nil, isDay: true, state: "", timeLeft: "")
    }
}

extension Kinepage {
    static func stub() -> Kinepage {
        .init(message: "", timestamp: .now)
    }
}

extension SentientOutpost {
    static func stub() -> SentientOutpost {
        .init(activation: .now, active: false, expiry: .now, id: "", mission: nil)
    }
}

extension Simaris {
    static func stub() -> Simaris {
        .init(isTargetActive: false, target: "")
    }
}

extension SteelPathOfferings {
    static func stub() -> SteelPathOfferings {
        .init(activation: .now, expiry: .now, remaining: "")
    }
}

extension VallisCycle {
    static func stub() -> VallisCycle {
        .init(activation: nil, expiry: nil, id: nil, isWarm: true, state: "")
    }
}

extension ZarimanCycle {
    static func stub() -> ZarimanCycle {
        .init(activation: nil, expiry: nil, id: nil, bountiesEndDate: nil, ec: nil, isCorpus: true, state: "", timeLeft: "")
    }
}

extension VoidTrader {
    static func stub(
        location: String = "",
        expiry: Date? = nil,
        inventory: [VoidTraderItem] = []
    ) -> VoidTrader {
        .init(
            activation: nil,
            expiry: expiry,
            id: nil,
            character: "",
            completed: nil,
            initialStart: .now,
            inventory: inventory,
            location: location,
            psId: "",
            schedule: []
        )
    }
}

extension Invasion {
    static func stub(
        id: String = UUID().uuidString,
        node: String = "",
        completion: Double = 0,
        completed: Bool = false,
        attacker: Faction = .stub(),
        defender: Faction = .stub()
    ) -> Invasion {
        .init(
            id: id,
            activation: .now,
            node: node,
            nodeKey: node,
            desc: "",
            attacker: attacker,
            defender: defender,
            vsInfestation: false,
            count: 0,
            requiredRuns: 0,
            completion: completion,
            completed: completed,
            rewardTypes: []
        )
    }
}

extension Faction {
    static func stub(reward: Reward? = nil, faction: String = "") -> Faction {
        .init(reward: reward, faction: faction, factionKey: faction)
    }
}

extension Reward {
    static func stub(items: [String] = [], countedItems: [CountedItem] = []) -> Reward {
        .init(items: items, countedItems: countedItems, credits: 0, thumbnail: nil, color: 0)
    }
}

extension Profile {
    static func stub(
        accountID: String = "stub-account",
        items: [ProfileItemModel] = [],
        playerSkills: [String: Int] = [:],
        missions: [ResultMission] = [],
        lastUpdated: Date = .now
    ) -> Profile {
        .init(
            accountID: .init(oid: accountID),
            displayName: "Stub Tenno",
            playerLevel: 0,
            items: items,
            playerSkills: playerSkills,
            missions: missions,
            accountStats: .empty,
            lastUpdated: lastUpdated
        )
    }
}

extension MasteryCatalog {
    static func stub(
        items: [CatalogContainer] = [],
        nonItemSources: [MasteryCategoryModel] = []
    ) -> MasteryCatalog {
        .init(
            schemaVersion: 1,
            gameVersion: "stub",
            generatedAt: .now,
            totalMasteryMax: 0,
            obtainableMasteryMax: 0,
            items: items,
            nonItemSources: nonItemSources
        )
    }
}

extension CatalogItemModel {
    static func stub(
        uniqueName: String = UUID().uuidString,
        name: String = "",
        category: Category = .suits,
        maxRank: Int = 5,
        pointsPerRank: Int = 1,
        xpPerRankSq: Int = 1000,
        obtainable: Bool = true
    ) -> CatalogItemModel {
        .init(
            uniqueName: uniqueName,
            name: name,
            category: category,
            maxRank: maxRank,
            pointsPerRank: pointsPerRank,
            xpPerRankSq: xpPerRankSq,
            icon: nil,
            obtainable: obtainable,
            requiresGilding: false
        )
    }
}
