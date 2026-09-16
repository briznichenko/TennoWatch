//
//  Endpoints.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

protocol EndpointProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var url: URL { get throws }
}

enum Platform: String {
    case pc, ps4, psn, xb1, swi, ns
}

enum ItemCategory: String {
    case weapons, warframes, items, mods
}

enum Endpoint {
    case worldState(platform: Platform)
    case catalog(ItemCategory)
    case profile(playerId: String)
}

extension Endpoint: EndpointProtocol {
    // MARK: - Computed Properties
    var baseURL: URL {
        switch self {
        case .catalog, .worldState:
            URL("https://api.warframestat.us")

        case .profile:
            URL("https://api.warframe.com")
        }
    }

    var path: String {
        switch self {
        case .worldState(let platform):
            platform.rawValue

        case .catalog(let category):
            category.rawValue

        case .profile:
            "cdn/getProfileViewingData.php"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .profile(let playerId): [URLQueryItem(name: "playerId", value: playerId)]
        default: []
        }
    }

    var url: URL {
        get throws {
            var components = URLComponents(
                url: baseURL.appending(path: path),
                resolvingAgainstBaseURL: false
            )
            
            components?.queryItems = queryItems
            
            guard let url = components?.url else {
                throw URLError(.badURL)
            }
            return url
        }
    }
}
