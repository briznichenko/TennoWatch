//
//  MasteryCategoryModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import Foundation

struct MasteryCategoryModel: Hashable, Identifiable {
    // MARK: - Object Properties
    let name: String
    var sources: [MasterySourceModel]
    let id = UUID()

    // MARK: - Computed Properties
    var itemsCount: Int { sources.count }
    var masteredItemsCount: Int {
        sources.filter {
            $0.isMastered == true
        }.count
    }

    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }

    // MARK: - Functions
    mutating func set(sources: [MasterySourceModel]) {
        self.sources = sources
    }
}

extension MasteryCategoryModel: PersistentModelConvertible {
    var model: MasteryCategoryDataModel {
        .init(name: name, sources: sources.map(\.model))
    }
}
