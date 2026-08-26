//
//  Profile.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

struct ProfileModel: Codable {
    let results: [ProfileInfoModel]
    let xpCacheExpiryDate: XPCacheExpiryDate
    let stats: Stats

    enum CodingKeys: String, CodingKey {
        case results = "Results"
        case xpCacheExpiryDate = "XpCacheExpiryDate"
        case stats = "Stats"
    }
}

struct ProfileInfoModel: Codable {
    let accountID: ID
    let displayName: String
    let platformNames: [String]
    let playerLevel: Int
    let loadOutPreset: LoadOutPreset
    let loadOutInventory: LoadOutInventory
    let guildID: ID
    let guildName: String
    let guildTier: Int
    let guildXP: Int
    let guildClass: Int
    let guildEmblem: Bool
    let allianceID: ID
    let playerSkills: [String: Int]
    let challengeProgress: [ChallengeProgress]
    let deathMarks: [String]
    let harvestable: Bool
    let deathSquadable: Bool
    let created: XPCacheExpiryDate
    let titleType: String
    let migratedToConsole: Bool
    let missions: [ResultMission]
    let affiliations: [Affiliation]
    let dailyAffiliation: Int
    let dailyAffiliationPvp: Int
    let dailyAffiliationLibrary: Int
    let dailyAffiliationCetus: Int
    let dailyAffiliationQuills: Int
    let dailyAffiliationSolaris: Int
    let dailyAffiliationVentkids: Int
    let dailyAffiliationVox: Int
    let dailyAffiliationEntrati: Int
    let dailyAffiliationNecraloid: Int
    let dailyAffiliationZariman: Int
    let dailyAffiliationKahl: Int
    let dailyAffiliationCavia: Int
    let dailyAffiliationHex: Int
    let dailyFocus: Int
    let operatorLoadOuts: [OperatorLoadOut]
    let unlockedOperator: Bool
    let unlockedAlignment: Bool
    let alignment: Alignment

    enum CodingKeys: String, CodingKey {
        case accountID = "AccountId"
        case displayName = "DisplayName"
        case platformNames = "PlatformNames"
        case playerLevel = "PlayerLevel"
        case loadOutPreset = "LoadOutPreset"
        case loadOutInventory = "LoadOutInventory"
        case guildID = "GuildId"
        case guildName = "GuildName"
        case guildTier = "GuildTier"
        case guildXP = "GuildXp"
        case guildClass = "GuildClass"
        case guildEmblem = "GuildEmblem"
        case allianceID = "AllianceId"
        case playerSkills = "PlayerSkills"
        case challengeProgress = "ChallengeProgress"
        case deathMarks = "DeathMarks"
        case harvestable = "Harvestable"
        case deathSquadable = "DeathSquadable"
        case created = "Created"
        case titleType = "TitleType"
        case migratedToConsole = "MigratedToConsole"
        case missions = "Missions"
        case affiliations = "Affiliations"
        case dailyAffiliation = "DailyAffiliation"
        case dailyAffiliationPvp = "DailyAffiliationPvp"
        case dailyAffiliationLibrary = "DailyAffiliationLibrary"
        case dailyAffiliationCetus = "DailyAffiliationCetus"
        case dailyAffiliationQuills = "DailyAffiliationQuills"
        case dailyAffiliationSolaris = "DailyAffiliationSolaris"
        case dailyAffiliationVentkids = "DailyAffiliationVentkids"
        case dailyAffiliationVox = "DailyAffiliationVox"
        case dailyAffiliationEntrati = "DailyAffiliationEntrati"
        case dailyAffiliationNecraloid = "DailyAffiliationNecraloid"
        case dailyAffiliationZariman = "DailyAffiliationZariman"
        case dailyAffiliationKahl = "DailyAffiliationKahl"
        case dailyAffiliationCavia = "DailyAffiliationCavia"
        case dailyAffiliationHex = "DailyAffiliationHex"
        case dailyFocus = "DailyFocus"
        case operatorLoadOuts = "OperatorLoadOuts"
        case unlockedOperator = "UnlockedOperator"
        case unlockedAlignment = "UnlockedAlignment"
        case alignment = "Alignment"
    }
}

// MARK: - ID
struct ID: Codable {
    let oid: String

    enum CodingKeys: String, CodingKey {
        case oid = "$oid"
    }
}

// MARK: - Affiliation
struct Affiliation: Codable {
    let tag: String
    let standing: Int
    let title: Int

    enum CodingKeys: String, CodingKey {
        case tag = "Tag"
        case standing = "Standing"
        case title = "Title"
    }
}

// MARK: - Alignment
struct Alignment: Codable {
    let alignment: Double
    let wisdom: Int

    enum CodingKeys: String, CodingKey {
        case alignment = "Alignment"
        case wisdom = "Wisdom"
    }
}

// MARK: - ChallengeProgress
struct ChallengeProgress: Codable {
    let name: String
    let progress: Int

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case progress = "Progress"
    }
}

// MARK: - XPCacheExpiryDate
struct XPCacheExpiryDate: Codable {
    let date: DateClass

    enum CodingKeys: String, CodingKey {
        case date = "$date"
    }
}

// MARK: - DateClass
struct DateClass: Codable {
    let numberLong: String

    enum CodingKeys: String, CodingKey {
        case numberLong = "$numberLong"
    }
}

// MARK: - LoadOutInventory
struct LoadOutInventory: Codable {
    let weaponSkins: [WeaponSkin]
    let suits: [Suit]
    let pistols: [LongGun]
    let longGuns: [LongGun]
    let xpInfo: [XPInfo]

    enum CodingKeys: String, CodingKey {
        case weaponSkins = "WeaponSkins"
        case suits = "Suits"
        case pistols = "Pistols"
        case longGuns = "LongGuns"
        case xpInfo = "XPInfo"
    }
}

// MARK: - LongGun
struct LongGun: Codable {
    let itemType: String
    let configs: [LongGunConfig]
    let upgradeVer: Int
    let xp: Int
    let features: Int
    let skillTree: String
    let polarity: [Polarity]
    let polarized: Int
    let focusLens: String
    let itemID: ID

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case configs = "Configs"
        case upgradeVer = "UpgradeVer"
        case xp = "XP"
        case features = "Features"
        case skillTree = "SkillTree"
        case polarity = "Polarity"
        case polarized = "Polarized"
        case focusLens = "FocusLens"
        case itemID = "ItemId"
    }
}

// MARK: - LongGunConfig
struct LongGunConfig: Codable {
    let skins: [String]
    let name: String
    let pricol: Cloth?

    enum CodingKeys: String, CodingKey {
        case skins = "Skins"
        case name = "Name"
        case pricol = "pricol"
    }
}

// MARK: - Cloth
struct Cloth: Codable {
    let t0: Int
    let t1: Int
    let t2: Int
    let t3: Int?
    let m0: Int?
    let m1: Int?
    let en: Int
    let e1: Int

    enum CodingKeys: String, CodingKey {
        case t0 = "t0"
        case t1 = "t1"
        case t2 = "t2"
        case t3 = "t3"
        case m0 = "m0"
        case m1 = "m1"
        case en = "en"
        case e1 = "e1"
    }
}

// MARK: - Polarity
struct Polarity: Codable {
    let slot: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case slot = "Slot"
        case value = "Value"
    }
}

// MARK: - Suit
struct Suit: Codable {
    let itemType: String
    let configs: [SuitConfig]
    let upgradeVer: Int
    let features: Int
    let xp: Int
    let polarity: [Polarity]
    let polarized: Int
    let archonCrystalUpgrades: [ArchonCrystalUpgrade]
    let infestationDate: XPCacheExpiryDate
    let itemID: ID

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case configs = "Configs"
        case upgradeVer = "UpgradeVer"
        case features = "Features"
        case xp = "XP"
        case polarity = "Polarity"
        case polarized = "Polarized"
        case archonCrystalUpgrades = "ArchonCrystalUpgrades"
        case infestationDate = "InfestationDate"
        case itemID = "ItemId"
    }
}

// MARK: - ArchonCrystalUpgrade
struct ArchonCrystalUpgrade: Codable {
    let color: String
    let upgradeType: String

    enum CodingKeys: String, CodingKey {
        case color = "Color"
        case upgradeType = "UpgradeType"
    }
}

// MARK: - SuitConfig
struct SuitConfig: Codable {
    let skins: [String]
    let attcol: Cloth
    let pricol: Cloth
    let abilityOverride: AbilityOverride?
    let syancol: Cloth
    let sigcol: Sigcol

    enum CodingKeys: String, CodingKey {
        case skins = "Skins"
        case attcol = "attcol"
        case pricol = "pricol"
        case abilityOverride = "AbilityOverride"
        case syancol = "syancol"
        case sigcol = "sigcol"
    }
}

// MARK: - AbilityOverride
struct AbilityOverride: Codable {
    let ability: String
    let index: Int

    enum CodingKeys: String, CodingKey {
        case ability = "Ability"
        case index = "Index"
    }
}

// MARK: - Sigcol
struct Sigcol: Codable {
    let e1: Int

    enum CodingKeys: String, CodingKey {
        case e1 = "e1"
    }
}

// MARK: - WeaponSkin
struct WeaponSkin: Codable {
    let itemType: String
    let favorite: Bool?

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case favorite = "Favorite"
    }
}

// MARK: - XPInfo
struct XPInfo: Codable {
    let itemType: String
    let xp: Int

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case xp = "XP"
    }
}

// MARK: - LoadOutPreset
struct LoadOutPreset: Codable {
    let focusSchool: String
    let presetIcon: String
    let favorite: Bool
    let n: String
    let s: H
    let p: H
    let l: H
    let m: M
    let h: H

    enum CodingKeys: String, CodingKey {
        case focusSchool = "FocusSchool"
        case presetIcon = "PresetIcon"
        case favorite = "Favorite"
        case n = "n"
        case s = "s"
        case p = "p"
        case l = "l"
        case m = "m"
        case h = "h"
    }
}

// MARK: - H
struct H: Codable {
    let itemID: ID
    let mod: Int
    let cus: Int

    enum CodingKeys: String, CodingKey {
        case itemID = "ItemId"
        case mod = "mod"
        case cus = "cus"
    }
}

// MARK: - M
struct M: Codable {
    let hide: Bool

    enum CodingKeys: String, CodingKey {
        case hide = "hide"
    }
}

// MARK: - ResultMission
struct ResultMission: Codable {
    let completes: Int
    let tier: Int?
    let tag: String

    enum CodingKeys: String, CodingKey {
        case completes = "Completes"
        case tier = "Tier"
        case tag = "Tag"
    }
}

// MARK: - OperatorLoadOut
struct OperatorLoadOut: Codable {
    let skins: [String]
    let facial: Cloth
    let pricol: Cloth
    let eyecol: Cloth
    let cloth: Cloth

    enum CodingKeys: String, CodingKey {
        case skins = "Skins"
        case facial = "facial"
        case pricol = "pricol"
        case eyecol = "eyecol"
        case cloth = "cloth"
    }
}

// MARK: - Stats
struct Stats: Codable {
    let ciphersFailed: Int
    let ciphersSolved: Int
    let cipherTime: Double
    let destroyCount: Int
    let fishCount: Int
    let deaths: Int
    let rating: Int
    let weapons: [Weapon]
    let enemies: [Enemy]
    let excavationEventScore: Int
    let healCount: Int
    let hiveEventScore: Int
    let hiveEventScoreSum: Int
    let income: Int
    let meleeKills: Int
    let missionsDumped: Int
    let missionsFailed: Int
    let missionsInterrupted: Int
    let missionsQuit: Int
    let missionsCompleted: Int
    let missions: [StatsMission]
    let timePlayedSEC: Double
    let pickupCount: Int
    let playerLevel: Int
    let pvp: [Pvp]
    let portalEventScore: Int
    let rank: Int
    let reviveCount: Int
    let scans: [Scan]
    let abilities: [Ability]
    let zephyrScore: Int
    let fomorianEventScore: Int
    let races: [String: Race]
    let pvpGamesPendingMask: Int
    let olliesCrashCourseScore: Int
    let guildName: String

    enum CodingKeys: String, CodingKey {
        case ciphersFailed = "CiphersFailed"
        case ciphersSolved = "CiphersSolved"
        case cipherTime = "CipherTime"
        case destroyCount = "DestroyCount"
        case fishCount = "FishCount"
        case deaths = "Deaths"
        case rating = "Rating"
        case weapons = "Weapons"
        case enemies = "Enemies"
        case excavationEventScore = "ExcavationEventScore"
        case healCount = "HealCount"
        case hiveEventScore = "HiveEventScore"
        case hiveEventScoreSum = "HiveEventScoreSum"
        case income = "Income"
        case meleeKills = "MeleeKills"
        case missionsDumped = "MissionsDumped"
        case missionsFailed = "MissionsFailed"
        case missionsInterrupted = "MissionsInterrupted"
        case missionsQuit = "MissionsQuit"
        case missionsCompleted = "MissionsCompleted"
        case missions = "Missions"
        case timePlayedSEC = "TimePlayedSec"
        case pickupCount = "PickupCount"
        case playerLevel = "PlayerLevel"
        case pvp = "PVP"
        case portalEventScore = "PortalEventScore"
        case rank = "Rank"
        case reviveCount = "ReviveCount"
        case scans = "Scans"
        case abilities = "Abilities"
        case zephyrScore = "ZephyrScore"
        case fomorianEventScore = "FomorianEventScore"
        case races = "Races"
        case pvpGamesPendingMask = "PvpGamesPendingMask"
        case olliesCrashCourseScore = "OlliesCrashCourseScore"
        case guildName = "GuildName"
    }
}

// MARK: - Ability
struct Ability: Codable {
    let used: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case used = "used"
        case type = "type"
    }
}

// MARK: - Enemy
struct Enemy: Codable {
    let executions: Int?
    let headshots: Int?
    let assists: Int?
    let kills: Int?
    let deaths: Int?
    let type: String
    let captures: Int?

    enum CodingKeys: String, CodingKey {
        case executions = "executions"
        case headshots = "headshots"
        case assists = "assists"
        case kills = "kills"
        case deaths = "deaths"
        case type = "type"
        case captures = "captures"
    }
}

// MARK: - StatsMission
struct StatsMission: Codable {
    let highScore: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case highScore = "highScore"
        case type = "type"
    }
}

// MARK: - Pvp
struct Pvp: Codable {
    let suitDeaths: Int?
    let suitKills: Int?
    let type: String
    let weaponKills: Int?

    enum CodingKeys: String, CodingKey {
        case suitDeaths = "suitDeaths"
        case suitKills = "suitKills"
        case type = "type"
        case weaponKills = "weaponKills"
    }
}

// MARK: - Race
struct Race: Codable {
    let highScore: Int

    enum CodingKeys: String, CodingKey {
        case highScore = "highScore"
    }
}

// MARK: - Scan
struct Scan: Codable {
    let scans: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case scans = "scans"
        case type = "type"
    }
}

// MARK: - Weapon
struct Weapon: Codable {
    let equipTime: Double?
    let headshots: Int?
    let hits: Int?
    let assists: Int?
    let kills: Int?
    let xp: Int?
    let type: String
    let fired: Int?

    enum CodingKeys: String, CodingKey {
        case equipTime = "equipTime"
        case headshots = "headshots"
        case hits = "hits"
        case assists = "assists"
        case kills = "kills"
        case xp = "xp"
        case type = "type"
        case fired = "fired"
    }
}
