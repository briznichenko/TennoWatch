//
//  Endpoints.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

protocol EndpointProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var url: URL { get }
}

enum Platform: String {
    case pc, ps4, psn, xb1, swi, ns
}

enum ItemCategory: String {
    case weapons, warframes, items, mods
}

enum Endpoint: EndpointProtocol {
    case invasions
    case worldState(platform: Platform)
    case catalog(ItemCategory)
    case profile(playerId: String)
    
    var baseURL: URL {
        switch self {
        case .invasions, .catalog(_:), .worldState(platform:):
            URL("https://api.warframestat.us")
        case .profile(playerId:):
            URL("https://api.warframe.com/cdn/getProfileViewingData.php")
        }
    }
    
    var path: String {
        switch self {
        case .invasions:
            "pc/invasions"
        case .worldState(let platform):
            platform.rawValue
        case .catalog(let category):
            category.rawValue
        case .profile(let playerId):
            ""
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .profile(let playerId):
            [URLQueryItem(name: "playerId", value: playerId)]
        default:
            []
        }
    }

    var url: URL {
        baseURL.appending(path: path).appending(queryItems: queryItems)
    }
}
