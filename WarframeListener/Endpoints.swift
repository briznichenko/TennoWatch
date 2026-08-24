//
//  Endpoints.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

enum Platform: String {
    case pc, ps4, psn, xb1, swi, ns
}

enum ItemCategory: String {
    case weapons, warframes, items, mods
}

enum Endpoint {
    case invasions
    case worldState(platform: Platform)
    case catalog(ItemCategory)
    case profile(playerId: String)

    private static let warframestatBaseURL = URL(string: "https://api.warframestat.us")!
    private static let profileBaseURL = URL(string: "https://api.warframe.com/cdn/getProfileViewingData.php")!

    var url: URL {
        switch self {
        case .invasions:
            Self.warframestatBaseURL.appending(path: "pc/invasions")
        case .worldState(let platform):
            Self.warframestatBaseURL.appending(path: platform.rawValue)
        case .catalog(let category):
            Self.warframestatBaseURL.appending(path: category.rawValue)
        case .profile(let playerId):
            Self.profileBaseURL.appending(queryItems: [URLQueryItem(name: "playerId", value: playerId)])
        }
    }
}
