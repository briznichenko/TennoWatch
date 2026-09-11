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
    enum State {
        case mastered, unmastered, partiallyMastered, unobtainable
    }
    
    private let item: MasteryItem
    let id = UUID()
    
    var name: String { item.catalogItemModel.name }
    var type: String { item.catalogItemModel.category.displayName }
    var uniqueName: String { item.catalogItemModel.uniqueName }
    var xp: Int { item.profileItemModel?.xp ?? 0 }
    var rank: Int {
        let calculatedRank = Int(Double(xp / item.catalogItemModel.xpPerRankSq).squareRoot())
        return min(calculatedRank, item.catalogItemModel.maxRank)
    }
    var maxRank: Int { item.catalogItemModel.maxRank }
    var rankText: String { "Rank: \(rank)/\(maxRank)" }
    
    var iconName: String {
        switch state {
        case .mastered: "checkmark.circle.fill"
        case .partiallyMastered: "circle.lefthalf.filled"
        case .unmastered: "circle.dashed"
        case .unobtainable: "lock.fill"
        }
    }
    
    var state: State {
        guard item.catalogItemModel.obtainable else { return .unobtainable }
        return switch rank {
        case 0: .unmastered
        case item.catalogItemModel.maxRank: .mastered
        default: .partiallyMastered
        }
    }
    
    init(item: MasteryItem) {
        self.item = item
    }
}
