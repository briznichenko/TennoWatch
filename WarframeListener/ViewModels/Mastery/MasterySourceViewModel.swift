//
//  MasterySourceViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import Observation
import Foundation

@Observable
final class MasterySourceViewModel: Identifiable {
    typealias State = MasteryItem.MasteryState

    private let source: MasterySourceModel
    let id = UUID()
    
    var name: String { source.name }
    var uniqueName: String { source.uniqueName }

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

    var state: State { source.isMastered == true ? .mastered : .unmastered }

    init(source: MasterySourceModel) {
        self.source = source
    }
}

extension MasterySourceModel {
    var masteryState: MasteryItem.MasteryState {
        isMastered == true ? .mastered : .unmastered
    }
}
