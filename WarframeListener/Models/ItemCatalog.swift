//
//  ItemCatalog.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation

// The OpenAPI spec doesn't mark any of these as required, but they're present on
// every item across /weapons, /warframes, /items, and /mods in practice — this is
// the shape needed to cross-reference against a player's per-item mastery XP.
// The one exception is `masterable`: the broader /items catalog omits it on
// ~4% of entries (non-masterable things like resources), so a missing key is
// treated the same as `false` rather than left optional.
struct CatalogItem: Decodable, Identifiable {
    var id: String { uniqueName }

    let uniqueName: String
    let name: String
    let `type`: String
    let category: String
    let tradable: Bool
    let masterable: Bool

    private enum CodingKeys: String, CodingKey {
        case uniqueName, name, `type`, category, tradable, masterable
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uniqueName = try container.decode(String.self, forKey: .uniqueName)
        name = try container.decode(String.self, forKey: .name)
        `type` = try container.decode(String.self, forKey: .type)
        category = try container.decode(String.self, forKey: .category)
        tradable = try container.decode(Bool.self, forKey: .tradable)
        masterable = try container.decodeIfPresent(Bool.self, forKey: .masterable) ?? false
    }
}
