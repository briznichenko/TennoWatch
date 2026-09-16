//
//  Profile.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

struct ProfileModel: NetworkModel {
    let results: [ProfileInfoModel]
    let stats: Stats

    enum CodingKeys: String, CodingKey {
        case results = "Results"
        case stats = "Stats"
    }
}

struct ProfileInfoModel: Decodable {
    let accountID: OID
    let displayName: String
    let platformNames: [String]
    let playerLevel: Int
    let loadOutPreset: LoadOutPreset?
//    let loadOutInventory: LoadOutInventory
    let guildID: OID
    let guildName: String
    let guildTier: Int
    let guildXP: Int
    let guildClass: Int
    let guildEmblem: Bool
    let allianceID: OID
    let playerSkills: [String: Int]
    let challengeProgress: [ChallengeProgress]
    let deathMarks: [String]
    let harvestable: Bool
    let deathSquadable: Bool
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
    let unlockedOperator: Bool
    let unlockedAlignment: Bool
    let alignment: Alignment

    enum CodingKeys: String, CodingKey {
        case accountID = "AccountId"
        case displayName = "DisplayName"
        case platformNames = "PlatformNames"
        case playerLevel = "PlayerLevel"
        case loadOutPreset = "LoadOutPreset"
//        case loadOutInventory = "LoadOutInventory"
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
        case unlockedOperator = "UnlockedOperator"
        case unlockedAlignment = "UnlockedAlignment"
        case alignment = "Alignment"
    }
}

// MARK: - ID
struct OID: Codable, Hashable {
    let oid: String

    enum CodingKeys: String, CodingKey {
        case oid = "$oid"
    }
}

// MARK: - Affiliation
struct Affiliation: Decodable {
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
struct Alignment: Decodable {
    let alignment: Double
    let wisdom: Int

    enum CodingKeys: String, CodingKey {
        case alignment = "Alignment"
        case wisdom = "Wisdom"
    }
}

// MARK: - ChallengeProgress
struct ChallengeProgress: Decodable {
    let name: String
    let progress: Int

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case progress = "Progress"
    }
}

// MARK: - LoadOutInventory
struct LoadOutInventory: Decodable {
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
struct LongGun: Decodable {
    let itemType: String
    let configs: [LongGunConfig]
    let upgradeVer: Int
    let xp: Int
    let features: Int
    let skillTree: String
    let polarity: [Polarity]
    let polarized: Int
    let focusLens: String
    let itemID: OID

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
struct LongGunConfig: Decodable {
    let skins: [String]
    let name: String

    enum CodingKeys: String, CodingKey {
        case skins = "Skins"
        case name = "Name"
    }
}

// MARK: - Polarity
struct Polarity: Decodable {
    let slot: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case slot = "Slot"
        case value = "Value"
    }
}

// MARK: - Suit
struct Suit: Decodable {
    let itemType: String
    let features: Int
    let xp: Int
    let polarity: [Polarity]
    let polarized: Int
    let archonCrystalUpgrades: [ArchonCrystalUpgrade]
    let itemID: OID

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case features = "Features"
        case xp = "XP"
        case polarity = "Polarity"
        case polarized = "Polarized"
        case archonCrystalUpgrades = "ArchonCrystalUpgrades"
        case itemID = "ItemId"
    }
}

// MARK: - ArchonCrystalUpgrade
struct ArchonCrystalUpgrade: Decodable {
    let color: String
    let upgradeType: String

    enum CodingKeys: String, CodingKey {
        case color = "Color"
        case upgradeType = "UpgradeType"
    }
}

// MARK: - WeaponSkin
struct WeaponSkin: Decodable {
    let itemType: String
    let favorite: Bool?

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case favorite = "Favorite"
    }
}

// MARK: - XPInfo
struct XPInfo: Decodable {
    let itemType: String
    let xp: Int

    enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case xp = "XP"
    }
}

// MARK: - LoadOutPreset
struct LoadOutPreset: Decodable {
    let focusSchool: String
    let presetIcon: String
    let favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case focusSchool = "FocusSchool"
        case presetIcon = "PresetIcon"
        case favorite = "Favorite"
    }
}

// MARK: - ResultMission
struct ResultMission: Codable, Hashable, Equatable {
    let completes: Int
    let tier: Int?
    let tag: String

    enum CodingKeys: String, CodingKey {
        case completes = "Completes"
        case tier = "Tier"
        case tag = "Tag"
    }
}

// MARK: - Stats
struct Stats: NetworkModel {
    let weapons: [ProfileItemModel]
    let deaths: Int
    let reviveCount: Int
    let meleeKills: Int
    let missionsCompleted: Int
    let timePlayedSec: Double
    let healCount: Int
    let income: Int
    let pickupCount: Int
    let fishCount: Int
    let destroyCount: Int
    let ciphersSolved: Int
    let ciphersFailed: Int
    
    enum CodingKeys: String, CodingKey {
        case weapons = "Weapons"
        case deaths = "Deaths"
        case reviveCount = "ReviveCount"
        case meleeKills = "MeleeKills"
        case missionsCompleted = "MissionsCompleted"
        case timePlayedSec = "TimePlayedSec"
        case healCount = "HealCount"
        case income = "Income"
        case pickupCount = "PickupCount"
        case fishCount = "FishCount"
        case destroyCount = "DestroyCount"
        case ciphersSolved = "CiphersSolved"
        case ciphersFailed = "CiphersFailed"
    }
}

struct StatsComplex: Decodable {
    let ciphersFailed: Int
    let ciphersSolved: Int
    let cipherTime: Double
    let destroyCount: Int
    let fishCount: Int
    let deaths: Int
    let rating: Int
    let weapons: [ProfileItemModel]
    let healCount: Int
    let income: Int
    let meleeKills: Int
    let missionsDumped: Int
    let missionsFailed: Int
    let missionsInterrupted: Int
    let missionsQuit: Int
    let missionsCompleted: Int
    let timePlayedSec: Double
    let pickupCount: Int
    let playerLevel: Int
    let rank: Int
    let reviveCount: Int
    let guildName: String
    
    enum CodingKeys: String, CodingKey {
        case weapons = "Weapons"
        case deaths = "Deaths"
        case reviveCount = "ReviveCount"
        case meleeKills = "MeleeKills"
        case missionsCompleted = "MissionsCompleted"
        case timePlayedSec = "TimePlayedSec"
        case healCount = "HealCount"
        case income = "Income"
        case pickupCount = "PickupCount"
        case fishCount = "FishCount"
        case destroyCount = "DestroyCount"
        case ciphersSolved = "CiphersSolved"
        case ciphersFailed = "CiphersFailed"
        case cipherTime = "CipherTime"
        case rating = "Rating"
        case missionsDumped = "MissionsDumped"
        case missionsFailed = "MissionsFailed"
        case missionsInterrupted = "MissionsInterrupted"
        case missionsQuit = "MissionsQuit"
        case playerLevel = "PlayerLevel"
        case rank = "Rank"
        case guildName = "GuildName"
    }

}
