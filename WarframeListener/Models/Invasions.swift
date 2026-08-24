//
//  Invasions.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

struct Invasion: Decodable, Identifiable {
    let id: String
    let activation: Date
    let node: String
    let nodeKey: String
    let desc: String
    let attacker: Faction
    let defender: Faction
    let vsInfestation: Bool
    let count: Int
    let requiredRuns: Int
    let completion: Double
    let completed: Bool
    let rewardTypes: [String]
}

struct Faction: Decodable {
    let reward: Reward?
    let faction: String
    let factionKey: String
}

struct Reward: Decodable {
    let items: [String]
    let countedItems: [CountedItem]
    let credits: Int
    let thumbnail: URL?
    let color: Int

    private enum CodingKeys: String, CodingKey {
        case items, countedItems, credits, thumbnail, color
    }

    init(items: [String], countedItems: [CountedItem], credits: Int, thumbnail: URL?, color: Int) {
        self.items = items
        self.countedItems = countedItems
        self.credits = credits
        self.thumbnail = thumbnail
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([String].self, forKey: .items)
        countedItems = try container.decode([CountedItem].self, forKey: .countedItems)
        credits = try container.decode(Int.self, forKey: .credits)
        color = try container.decode(Int.self, forKey: .color)
        // Some rewards (e.g. certain alerts) have an empty thumbnail string, which
        // URL's Decodable conformance treats as invalid rather than nil — decode it
        // as a plain string first so an empty thumbnail becomes nil instead of a
        // decode failure for the whole object.
        let thumbnailString = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        thumbnail = thumbnailString.flatMap { $0.isEmpty ? nil : URL(string: $0) }
    }
}

struct CountedItem: Decodable {
    let count: Int
    let type: String
    let key: String
}
