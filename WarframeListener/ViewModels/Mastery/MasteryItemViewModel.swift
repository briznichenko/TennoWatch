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
    
    private let item: MasteryItemContainer
    let id = UUID()
    
    var name: String { item.catalogItem.name }
    var type: String { item.catalogItem.category.displayName }
    var uniqueName: String { item.catalogItem.uniqueName }
    var xp: Int { item.profileItem?.xp ?? 0 }
    var rank: Int {
        let calculatedRank = Int(Double(xp / item.catalogItem.xpPerRankSq).squareRoot())
        return min(calculatedRank, item.catalogItem.maxRank)
    }
    var maxRank: Int { item.catalogItem.maxRank }
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
        guard item.catalogItem.obtainable else { return .unobtainable }
        return switch rank {
        case 0: .unmastered
        case item.catalogItem.maxRank: .mastered
        default: .partiallyMastered
        }
    }
    
    init(item: MasteryItemContainer) {
        self.item = item
    }
}
