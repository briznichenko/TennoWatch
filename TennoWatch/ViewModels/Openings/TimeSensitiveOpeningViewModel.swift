//
//  TimeSensitiveOpeningViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Observation
import Foundation

@Observable
final class TimeSensitiveOpeningViewModel: Identifiable {
    // MARK: - Object Properties
    private let opening: TimeSensitiveOpening
    let id = UUID()

    // MARK: - Computed Properties
    var name: String { opening.item.catalogItemModel.name }
    var type: String { opening.item.catalogItemModel.category.displayName }
    var iconName: String { "bolt.circle.fill" }

    var sourceText: String {
        switch opening.source {
        case .invasion(let node, let faction, let completion):
            Strings.Openings.invasionSource(node: node, faction: faction, percent: Int(completion.rounded()))
        case .voidTrader(let location, let expiry):
            Strings.Openings.voidTraderSource(location: location, timeLeft: expiry?.timeLeftDescription ?? "")
        }
    }

    // MARK: - Init
    init(opening: TimeSensitiveOpening) {
        self.opening = opening
    }
}
