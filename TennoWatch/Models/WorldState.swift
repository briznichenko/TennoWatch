//
//  WorldState.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

struct ArchimedeaMissionDifficultyRisk: NetworkModel {
    let description: String
    let isHard: Bool
    let key: String
    let name: String
}

struct ArchimedeaMissionDifficulty: NetworkModel {
    let description: String
    let key: String
    let name: String
}

struct ExternalMission: NetworkModel {
    let activation: Date
    let archwing: Bool
    let enemy: String?
    let expired: Bool
    let expiry: Date
    let id: String
    let node: String
    let nodeKey: String
    let sharkwing: Bool
    let `type`: String
    let typeKey: String
}

struct ArchimedeaMission: NetworkModel {
    let deviation: ArchimedeaMissionDifficulty
    let faction: String
    let factionKey: String
    let missionType: String
    let missionTypeKey: String
    let risks: [ArchimedeaMissionDifficultyRisk]
}

struct PersonalModifier: NetworkModel {
    let description: String
    let key: String
    let name: String
}

struct Archimedea: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let missions: [ArchimedeaMission]
    let personalModifiers: [PersonalModifier]
    let `type`: String
    let typeKey: String
}

struct Alert: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let mission: Mission
    let rewardTypes: [String]
    let tag: String?
}

struct InterimStep: NetworkModel {
    let goal: Double
    let reward: Reward?
    let winnerCount: Double?
}

struct RewardDrop: NetworkModel {
    let count: Double
}

struct SyndicateJob: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let enemyLevels: [Double]
    let isVault: Bool?
    let locationTag: String?
    let minMR: Double
    let rewardPool: [String]
    let rewardPoolDrops: [RewardDrop]
    let standingStages: [Double]
    let timeBound: String?
    let `type`: String?
    let uniqueName: String
}

struct ProgressStep: NetworkModel {
    let `type`: String
    let progressAmt: Double
}

struct WorldEvent: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let affiliatedWith: String?
    let altActivation: Date
    let altExpiry: Date
    let archwingDrops: [String]
    let completionBonuses: [Double]
    let concurrentNodes: [String]
    let currentScore: Double?
    let description: String
    let faction: String?
    let health: Double?
    let interimSteps: [InterimStep]
    let isCommunity: Bool
    let isPersonal: Bool?
    let jobs: [SyndicateJob]
    let largeInterval: Double?
    let maximumScore: Double?
    let node: String?
    let previousId: String?
    let previousJobs: [SyndicateJob]
    let progressSteps: [ProgressStep]
    let progressTotal: Double?
    let regionDrops: [String]
    let rewards: [Reward]
    let scoreLocTag: String?
    let scoreVar: String?
    let showTotalAtEndOfMission: Bool
    let smallInterval: Double?
    let tag: String
    let tooltip: String?
    let victim: String?
    let victimNode: String?
}

struct CalendarChallenge: NetworkModel {
    let title: String
    let description: String
}

struct CalendarUpgrade: NetworkModel {
    let title: String
    let description: String
}

struct CalendarEvent: NetworkModel {
    let `type`: String
    let challenge: CalendarChallenge?
    let reward: String?
    let uniqueName: String?
    let upgrade: CalendarUpgrade?
}

struct CalendarDay: NetworkModel {
    let date: Date
    let events: [CalendarEvent]
}

struct GameCalendar: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let days: [CalendarDay]
    let requirements: [String]
    let season: String
    let version: Double
    let yearIteration: Double
}

struct CambionCycle: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let state: String
    let timeLeft: String
}

struct CetusCycle: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let isCetus: Bool
    let isDay: Bool
    let state: String
    let timeLeft: String
}

struct VallisCycle: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let isWarm: Bool
    let state: String
}

struct EarthCycle: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let isDay: Bool
    let state: String
    let timeLeft: String
}

struct ZarimanCycle: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let bountiesEndDate: Date?
    let ec: CurrentZarimanCycle?
    let isCorpus: Bool
    let state: String
    let timeLeft: String
}

struct CurrentZarimanCycle: NetworkModel {
    let isCorpus: Bool
    let timeLeft: String
    let expiry: Date
    let expiresIn: Double
    let state: String
    let start: Double
}

struct ClanReward: NetworkModel {
    let rewardClaimed: Bool
    let pointThreshold: Double
    let itemCount: Double
    let reward: String

    private enum CodingKeys: String, CodingKey {
        case rewardClaimed = "RewardClaimed"
        case pointThreshold = "PointThreshold"
        case itemCount = "ItemCount"
        case reward = "Reward"
    }
}

struct ClanInitiativeRewards: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let bonusRegion: String
    let regionUniqueName: String
    let rewwards: [ClanReward]
    let week: Double
}

struct ConclaveChallenge: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let amount: Double
    let category: String
    let categoryKey: String
    let daily: Bool
    let description: String?
    let mode: String
    let rootChallenge: Bool
    let standing: Double?
    let title: String?
}

struct ConstructionProgress: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let fomorianProgress: String
    let razorbackProgress: String
    let unknownProgress: String
}

struct DailyDeal: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let discount: Double
    let item: String
    let originalPrice: Double
    let salePrice: Double
    let sold: Double
    let total: Double
    let uniqueName: String
}

struct DarkSectorBattle: NetworkModel {
    let attacker: String
    let attackerIsAlliance: Bool
    let defender: String
    let defenderIsAlliance: Bool
    let end: Date
    let start: Date
    let winner: String
}

struct DarkSector: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let battlePayReserve: Double
    let battlePaySetBy: String
    let battlePaySetByClan: String
    let creditTaxRate: Double
    let damagePerMission: Double
    let defenderMOTD: String
    let defenderMaxPool: Double
    let defenderName: String
    let defenderPoolRemaining: Double
    let defenderRailHealReserve: Double
    let deployerClan: String
    let deployerName: String
    let healRate: Double
    let history: [DarkSectorBattle]
    let isAlliance: Bool
    let itemsTaxRate: Double
    let memberCreditsTaxRate: Double
    let memberItemsTaxRate: Double
    let mission: Mission?
    let perMissionBattlePay: Double
    let railType: String
    let taxChangedBy: String
    let taxChangedByClan: String
}

struct DuviriChoice: NetworkModel {
    let category: String
    let categoryKey: String
    let choices: [String]
}

struct DuviriCycle: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let choices: [DuviriChoice]
    let state: String
}

struct Fissure: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let enemy: String
    let enemyKey: String
    let isHard: Bool
    let isStorm: Bool
    let missionType: String
    let missionTypeKey: String
    let node: String
    let nodeKey: String
    let tier: String
}

struct FlashSale: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let discount: Double?
    let isFeatured: Bool?
    let isPopular: Bool?
    let isShownInMarket: Bool?
    let item: String
    let premiumOverride: Double?
    let regularOverride: Double?
}

struct GlobalUpgrade: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let operation: String
    let operationSymbol: String
    let upgrade: String
    let upgradeOperationValue: Double
}

struct Kinepage: NetworkModel {
    let message: String
    let timestamp: Date
}

struct Mission: NetworkModel {
    let advancedSpawners: [String]
    let archwingRequired: Bool
    let consumeRequiredItems: Bool?
    let description: String?
    let enemySpec: String?
    let exclusiveWeapon: String?
    let faction: String?
    let factionKey: String?
    let goalTag: String?
    let isSharkwing: Bool
    let leadersAlwaysAllowed: Bool?
    let levelAuras: [String]
    let levelOverride: String?
    let maxEnemyLevel: Double?
    let maxWaveNum: Double?
    let minEnemyLevel: Double?
    let nightmare: Bool
    let node: String
    let nodeKey: String
    let requiredItems: [String]
    let reward: Reward?
    let target: String?
    let `type`: String
    let typeKey: String
}

struct SortieVariant: NetworkModel {
    let missionType: String
    let missionTypeKey: String
    let modifier: String
    let modifierDescription: String
    let node: String
    let nodeKey: String
}

struct Sortie: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let boss: String
    let faction: String
    let factionKey: String
    let missions: [Mission]
    let rewardPool: String
    let variants: [SortieVariant]
}

/// Archon Hunt has no reward field in the API response, but its guaranteed
/// (non-Tauforged) drop is implied by which Archon is this week's boss.
enum ArchonHuntReward: String, CaseIterable {
    case crimson
    case amber
    case azure

    init?(archonBoss boss: String) {
        switch boss {
        case "Archon Amar": self = .crimson
        case "Archon Nira": self = .amber
        case "Archon Boreal": self = .azure
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .crimson: Strings.WorldState.archonHuntRewardCrimson
        case .amber: Strings.WorldState.archonHuntRewardAmber
        case .azure: Strings.WorldState.archonHuntRewardAzure
        }
    }
}

extension Sortie {
    var archonHuntReward: ArchonHuntReward? { ArchonHuntReward(archonBoss: boss) }
}

struct News: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let date: Date
    let imageLink: String
    let link: String
    let message: String
    let mobileOnly: Bool?
    let primeAccess: Bool
    let priority: Bool?
    let stream: Bool
    let update: Bool
}

struct NightwaveChallenge: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let desc: String
    let isDaily: Bool
    let isElite: Bool
    let isPermanent: Bool
    let reputation: Double
    let title: String
}

struct Nightwave: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let activeChallenges: [NightwaveChallenge]
    let phase: Double
    let possibleChallenges: [NightwaveChallenge]
    let season: Double
    let tag: String
}

struct OutpostMission: NetworkModel {
    let node: String
    let faction: String
    let `type`: String
}

struct SentientOutpost: NetworkModel {
    let activation: Date
    let active: Bool
    let expiry: Date
    let id: String
    let mission: OutpostMission?
}

struct PersistentEnemy: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let agentType: String
    let fleeDamage: Double
    let healthPercent: Double
    let isDiscovered: Bool
    let isUsingTicketing: Bool
    let lastDiscoveredAt: String
    let lastDiscoveredTime: Date
    let locationTag: String
    let pid: String
    let rank: Double
}

struct Simaris: NetworkModel {
    let isTargetActive: Bool
    let target: String
}

struct SteelPathReward: NetworkModel {
    let name: String
    let cost: Double
}

struct SteelPathIncursion: NetworkModel {
    let id: String?
    let activation: Date?
    let expiry: Date?
}

struct SteelPathOfferings: NetworkModel {
    let activation: Date
    let expiry: Date
    let remaining: String
    let currentReward: SteelPathReward?
    let rotation: [SteelPathReward]
    let evergreens: [SteelPathReward]
    let incursions: SteelPathIncursion?
}

struct SyndicateMission: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let jobs: [SyndicateJob]
    let nodes: [String]
    let syndicate: String
    let syndicateKey: String
}

struct ChallengeInstance: NetworkModel {
    let damageType: String?
    let minEnemyLevel: Double
    let progressAmount: Double
    let requiredAmount: Double
    let target: String?
    let `type`: String
}

struct WeeklyChallenge: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let challenges: [ChallengeInstance]
}

struct VoidTraderItem: NetworkModel {
    let credits: Double?
    let ducats: Double?
    let item: String
    let uniqueName: String
}

struct VoidTraderSchedule: NetworkModel {
    let expiry: Date
    let item: String?
}

struct VoidTrader: NetworkModel {
    let activation: Date?
    let expiry: Date?
    let id: String?
    let character: String
    let completed: Bool?
    let initialStart: Date
    let inventory: [VoidTraderItem]
    let location: String
    let psId: String
    let schedule: [VoidTraderSchedule]
}

struct WorldState: NetworkModel {
    let alerts: [Alert]
    let arbitration: ExternalMission?
    let archimedeas: [Archimedea]
    let archonHunt: Sortie
    let buildLabel: String
    let calendar: GameCalendar
    let cambionCycle: CambionCycle
    let cetusCycle: CetusCycle
    let clanWeeklyInitiative: ClanInitiativeRewards?
    let conclaveChallenges: [ConclaveChallenge]
    let constructionProgress: ConstructionProgress
    let dailyDeals: [DailyDeal]
    let darkSectors: [DarkSector]
    let duviriCycle: DuviriCycle
    let earthCycle: EarthCycle
    let events: [WorldEvent]
    let fissures: [Fissure]
    let flashSales: [FlashSale]
    let globalUpgrades: [GlobalUpgrade]
    let invasions: [Invasion]
    let kinepage: Kinepage
    let kuva: [ExternalMission]?
    let news: [News]
    let nightwave: Nightwave?
    let persistentEnemies: [PersistentEnemy]
    let sentientOutposts: SentientOutpost
    let simaris: Simaris
    let sortie: Sortie
    let steelPath: SteelPathOfferings
    let syndicateMissions: [SyndicateMission]
    let timestamp: Date
    let vallisCycle: VallisCycle
    let vaultTrader: VoidTrader
    let voidTrader: VoidTrader
    let voidTraders: [VoidTrader]
    let weeklyChallenges: WeeklyChallenge?
    let zarimanCycle: ZarimanCycle
}
