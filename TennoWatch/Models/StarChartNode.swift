//
//  StarChartNode.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import Foundation

struct StarChartNode: Decodable {
    let name: String
    let missionType: String?

    var planet: String? { name.nodeNameAndPlanet.planet }
    var detailText: String {
        [planet, missionType].compactMap { $0 }.joined(separator: " · ")
    }

    private enum CodingKeys: String, CodingKey {
        case name = "value"
        case missionType = "type"
    }

    private static let nodes: [String: StarChartNode] = {
        guard let url = Bundle.main.url(forResource: "solNodes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let nodes = try? JSONDecoder().decode([String: StarChartNode].self, from: data) else {
            return [:]
        }
        return nodes
    }()

    static func node(for uniqueName: String) -> StarChartNode? {
        let key = uniqueName.hasSuffix(StarChartRules.steelPathSuffix)
            ? String(uniqueName.dropLast(StarChartRules.steelPathSuffix.count))
            : uniqueName
        return nodes[key]
    }
}

extension MasterySourceModel {
    var nodeDetails: String? {
        guard let details = StarChartNode.node(for: uniqueName)?.detailText, !details.isEmpty else { return nil }
        return details
    }

    var searchableText: String {
        [name, uniqueName, nodeDetails].compactMap { $0 }.joined(separator: " ")
    }
}
