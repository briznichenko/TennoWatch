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

    var id: String { opening.id }

    // MARK: - Computed Properties
    var name: String { opening.item.catalogItemModel.name }
    var type: String { opening.item.catalogItemModel.category.displayName }
    var iconName: String { opening.item.catalogItemModel.category.iconName }

    var sourceName: String {
        switch opening.source {
        case .invasion: Strings.WorldState.invasionsHeader
        case .voidTrader: Strings.WorldState.voidTraderHeader
        case .vaultTrader: Strings.WorldState.vaultTraderHeader
        }
    }

    var location: String {
        switch opening.source {
        case .invasion(let node, let faction, _): "\(node) · \(faction)"
        case .voidTrader(let location, _), .vaultTrader(let location, _): location
        }
    }

    var expiry: Date? {
        switch opening.source {
        case .invasion: nil
        case .voidTrader(_, let expiry), .vaultTrader(_, let expiry): expiry
        }
    }

    var completion: Double? {
        guard case .invasion(_, _, let completion) = opening.source else { return nil }
        return completion / 100
    }

    var sourceText: String {
        switch opening.source {
        case .invasion(let node, let faction, let completion):
            Strings.Openings.invasionSource(node: node, faction: faction, percent: Int(completion.rounded()))
        case .voidTrader(let location, let expiry):
            Strings.Openings.voidTraderSource(location: location, timeLeft: expiry?.timeLeftDescription ?? "")
        case .vaultTrader(let location, let expiry):
            Strings.Openings.vaultTraderSource(location: location, timeLeft: expiry?.timeLeftDescription ?? "")
        }
    }

    // MARK: - Init
    init(opening: TimeSensitiveOpening) {
        self.opening = opening
    }
}
