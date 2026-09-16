//
//  Invasions.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

struct Invasion: NetworkModel, Identifiable {
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

struct Faction: NetworkModel {
    let reward: Reward?
    let faction: String
    let factionKey: String
}

struct Reward: NetworkModel {
    // MARK: - Object Properties
    let items: [String]
    let countedItems: [CountedItem]
    let credits: Int
    let thumbnail: URL?
    let color: Int

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case items, countedItems, credits, thumbnail, color
    }

    // MARK: - Init
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
        let thumbnailString = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        thumbnail = thumbnailString.flatMap { $0.isEmpty ? nil : URL(string: $0) }
    }
}

struct CountedItem: NetworkModel {
    let uniqueName: String?
    let count: Int
    let type: String
    let key: String

    init(uniqueName: String? = nil, count: Int, type: String, key: String) {
        self.uniqueName = uniqueName
        self.count = count
        self.type = type
        self.key = key
    }
}
