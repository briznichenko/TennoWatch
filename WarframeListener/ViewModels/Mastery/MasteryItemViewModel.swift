//
//  MasteryItemViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Observation
import Foundation

@Observable
final class MasteryItemViewModel: Identifiable {
    typealias State = MasteryItem.MasteryState

    private let item: MasteryItem
    let id = UUID()
    
    var name: String { item.catalogItemModel.name }
    var type: String { item.catalogItemModel.category.displayName }
    var uniqueName: String { item.catalogItemModel.uniqueName }
    var rank: Int { item.rank }
    var maxRank: Int { item.catalogItemModel.maxRank }
    var pointsRemaining: Int { item.remainingMasteryPoints }
    var isObtainable: Bool { item.catalogItemModel.obtainable }

    var detailText: String {
        switch state {
        case .mastered: "Mastered"
        case .unobtainable: "Unobtainable"
        case .unmastered, .partiallyMastered: "Rank \(rank) / \(maxRank) · +\(pointsRemaining) left"
        }
    }

    var iconName: String {
        switch state {
        case .mastered: "checkmark.circle.fill"
        case .partiallyMastered: "circle.lefthalf.filled"
        case .unmastered: "circle.dashed"
        case .unobtainable: "lock.fill"
        }
    }

    var isDimmed: Bool {
        switch state {
        case .mastered, .unobtainable: true
        case .unmastered, .partiallyMastered: false
        }
    }

    var state: State { item.masteryState }

    init(item: MasteryItem) {
        self.item = item
    }
}


