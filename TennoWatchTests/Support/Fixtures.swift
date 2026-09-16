//
//  Fixtures.swift
//  TennoWatchTests
//

import Foundation
@testable import TennoWatch

extension WorldState {
    static func stub(
        invasions: [Invasion] = [],
        voidTrader: VoidTrader = .stub(),
        fissures: [Fissure] = [],
        cambionCycle: CambionCycle = .stub(),
        cetusCycle: CetusCycle = .stub(),
        earthCycle: EarthCycle = .stub(),
        vallisCycle: VallisCycle = .stub(),
        zarimanCycle: ZarimanCycle = .stub()
    ) -> WorldState {
        WorldState(
            alerts: [],
            arbitration: nil,
            archimedeas: [],
            archonHunt: .stub(),
            buildLabel: "",
            calendar: .stub(),
            cambionCycle: cambionCycle,
            cetusCycle: cetusCycle,
            clanWeeklyInitiative: nil,
            conclaveChallenges: [],
            constructionProgress: .stub(),
            dailyDeals: [],
            darkSectors: [],
            duviriCycle: .stub(),
            earthCycle: earthCycle,
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
            vallisCycle: vallisCycle,
            vaultTrader: .stub(),
            voidTrader: voidTrader,
            voidTraders: [],
            weeklyChallenges: nil,
            zarimanCycle: zarimanCycle
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
    static func stub(state: String = "", timeLeft: String = "") -> CambionCycle {
        .init(activation: nil, expiry: nil, id: nil, state: state, timeLeft: timeLeft)
    }
}

extension CetusCycle {
    static func stub(isDay: Bool = true, timeLeft: String = "") -> CetusCycle {
        .init(activation: nil, expiry: nil, id: nil, isCetus: false, isDay: isDay, state: "", timeLeft: timeLeft)
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
    static func stub(isDay: Bool = true, timeLeft: String = "") -> EarthCycle {
        .init(activation: nil, expiry: nil, id: nil, isDay: isDay, state: "", timeLeft: timeLeft)
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
    static func stub(isWarm: Bool = true, expiry: Date? = nil) -> VallisCycle {
        .init(activation: nil, expiry: expiry, id: nil, isWarm: isWarm, state: "")
    }
}

extension ZarimanCycle {
    static func stub(isCorpus: Bool = true, timeLeft: String = "") -> ZarimanCycle {
        .init(activation: nil, expiry: nil, id: nil, bountiesEndDate: nil, ec: nil, isCorpus: isCorpus, state: "", timeLeft: timeLeft)
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

extension Fissure {
    static func stub(node: String = "", expiry: Date? = nil) -> Fissure {
        .init(
            activation: nil,
            expiry: expiry,
            id: nil,
            enemy: "",
            enemyKey: "",
            isHard: false,
            isStorm: false,
            missionType: "",
            missionTypeKey: "",
            node: node,
            nodeKey: node,
            tier: ""
        )
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

extension OID {
    static func stub(_ oid: String = "stub-oid") -> OID {
        .init(oid: oid)
    }
}

extension Alignment {
    static func stub() -> Alignment {
        .init(alignment: 0, wisdom: 0)
    }
}

extension ProfileInfoModel {
    static func stub(
        accountID: String = "stub-account",
        displayName: String = "Stub Tenno",
        playerLevel: Int = 0,
        playerSkills: [String: Int] = [:],
        missions: [ResultMission] = []
    ) -> ProfileInfoModel {
        .init(
            accountID: .stub(accountID),
            displayName: displayName,
            platformNames: [],
            playerLevel: playerLevel,
            loadOutPreset: nil,
            guildID: .stub(),
            guildName: "",
            guildTier: 0,
            guildXP: 0,
            guildClass: 0,
            guildEmblem: false,
            allianceID: .stub(),
            playerSkills: playerSkills,
            challengeProgress: [],
            deathMarks: [],
            harvestable: false,
            deathSquadable: false,
            titleType: "",
            migratedToConsole: false,
            missions: missions,
            affiliations: [],
            dailyAffiliation: 0,
            dailyAffiliationPvp: 0,
            dailyAffiliationLibrary: 0,
            dailyAffiliationCetus: 0,
            dailyAffiliationQuills: 0,
            dailyAffiliationSolaris: 0,
            dailyAffiliationVentkids: 0,
            dailyAffiliationVox: 0,
            dailyAffiliationEntrati: 0,
            dailyAffiliationNecraloid: 0,
            dailyAffiliationZariman: 0,
            dailyAffiliationKahl: 0,
            dailyAffiliationCavia: 0,
            dailyAffiliationHex: 0,
            dailyFocus: 0,
            unlockedOperator: false,
            unlockedAlignment: false,
            alignment: .stub()
        )
    }
}

extension Stats {
    static func stub(weapons: [ProfileItemModel] = []) -> Stats {
        .init(
            weapons: weapons,
            deaths: 0,
            reviveCount: 0,
            meleeKills: 0,
            missionsCompleted: 0,
            timePlayedSec: 0,
            healCount: 0,
            income: 0,
            pickupCount: 0,
            fishCount: 0,
            destroyCount: 0,
            ciphersSolved: 0,
            ciphersFailed: 0
        )
    }
}

extension ProfileModel {
    static func stub(results: [ProfileInfoModel] = [], stats: Stats = .stub()) -> ProfileModel {
        .init(results: results, stats: stats)
    }
}
