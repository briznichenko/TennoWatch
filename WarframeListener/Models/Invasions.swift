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
}

struct CountedItem: Decodable {
    let count: Int
    let type: String
    let key: String
}
