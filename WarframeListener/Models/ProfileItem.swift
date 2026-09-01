//
//  ProfileItem.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//


// MARK: - Weapon
struct ProfileItem: Codable {
    let equipTime: Double?
    let headshots: Int?
    let hits: Int?
    let assists: Int?
    let kills: Int?
    let xp: Int?
    let type: String
    let fired: Int?
    
    static let stub = Self.init(equipTime: 10, headshots: 2, hits: 5, assists: 3, kills: 2, xp: 1000, type: "type", fired: 100)
}
