//
//  MasteryCategoryModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import Foundation

struct MasteryCategoryModel: Hashable, Identifiable {
    let name: String
    var sources: [MasterySourceModel]
    
    var itemsCount: Int { sources.count }
    var masteredItemsCount: Int {
        sources.filter {
            $0.isMastered == true
        }.count
    }

    var countText: String { "\(masteredItemsCount) / \(itemsCount)" }
    let id = UUID()
    
    mutating func set(sources: [MasterySourceModel]) {
        self.sources = sources
    }
}

extension MasteryCategoryModel: PersistentModelConvertible {
    var model: MasteryCategoryDataModel {
        .init(name: name, sources: sources.map(\.model))
    }
}
