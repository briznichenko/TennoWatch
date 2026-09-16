//
//  TimeSensitiveOpening.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Foundation

struct TimeSensitiveOpening: Identifiable, Hashable {
    enum Source: Hashable {
        case invasion(node: String, faction: String, completion: Double)
        case voidTrader(location: String, expiry: Date?)
    }

    // MARK: - Object Properties
    let item: MasteryItem
    let source: Source

    // MARK: - Computed Properties
    var id: String { item.catalogItemModel.uniqueName }
}
