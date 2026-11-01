//
//  FissureStarChart.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import Foundation

enum FissureStarChart: String, CaseIterable, Identifiable {
    case normal, steelPath, railjack

    var id: Self { self }

    var title: String {
        switch self {
        case .normal: Strings.WorldState.normalStarChart
        case .steelPath: Strings.Mastery.steelPath
        case .railjack: Strings.WorldState.railjackStarChart
        }
    }
}

extension Fissure {
    var starChart: FissureStarChart {
        if isStorm { return .railjack }
        return isHard ? .steelPath : .normal
    }
}
