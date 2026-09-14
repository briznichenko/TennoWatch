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

    // MARK: - Object Properties
    private let item: MasteryItem
    let id = UUID()

    // MARK: - Computed Properties
    var name: String { item.catalogItemModel.name }
    var type: String { item.catalogItemModel.category.displayName }
    var uniqueName: String { item.catalogItemModel.uniqueName }
    var rank: Int { item.rank }
    var maxRank: Int { item.catalogItemModel.maxRank }
    var pointsRemaining: Int { item.remainingMasteryPoints }
    var isObtainable: Bool { item.catalogItemModel.obtainable }

    var detailText: String {
        switch state {
        case .mastered: Strings.Mastery.itemStateMastered
        case .unobtainable: Strings.Mastery.itemStateUnobtainable
        case .unmastered, .partiallyMastered: Strings.Mastery.itemRankProgress(rank: rank, maxRank: maxRank, pointsRemaining: pointsRemaining)
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

    // MARK: - Init
    init(item: MasteryItem) {
        self.item = item
    }
}
