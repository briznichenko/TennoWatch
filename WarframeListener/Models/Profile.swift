//
//  Profile.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

// Not part of the given OpenAPI collection — that spec's own /profile endpoints
// (api.warframestat.us) return 404 for every player tried. This models DE's own
// profile host (api.warframe.com/cdn/getProfileViewingData.php) instead, derived
// from a real response rather than a schema, and scoped to just identity + the
// per-item mastery XP list — the rest of that payload (guild, loadout presets,
// combat stats) isn't modeled since it's outside what's needed right now.

struct MongoObjectId: Decodable {
    let oid: String

    private enum CodingKeys: String, CodingKey {
        case oid = "$oid"
    }
}

struct ItemXP: Decodable {
    let itemType: String
    let xp: Int

    private enum CodingKeys: String, CodingKey {
        case itemType = "ItemType"
        case xp = "XP"
    }
}

struct LoadOutInventory: Decodable {
    let xpInfo: [ItemXP]

    private enum CodingKeys: String, CodingKey {
        case xpInfo = "XPInfo"
    }
}

struct PlayerProfile: Decodable {
    let accountId: MongoObjectId
    let displayName: String
    let playerLevel: Int
    let loadOutInventory: LoadOutInventory

    private enum CodingKeys: String, CodingKey {
        case accountId = "AccountId"
        case displayName = "DisplayName"
        case playerLevel = "PlayerLevel"
        case loadOutInventory = "LoadOutInventory"
    }
}

struct ProfileViewingData: Decodable {
    let results: [PlayerProfile]

    private enum CodingKeys: String, CodingKey {
        case results = "Results"
    }
}
