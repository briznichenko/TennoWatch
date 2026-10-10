import Foundation

enum StarChartMode: String, CaseIterable, Identifiable {
    case base, steelPath

    var id: Self { self }
    var title: String {
        switch self {
        case .base: Strings.Mastery.baseStarChart
        case .steelPath: Strings.Mastery.steelPath
        }
    }

    static func sections<Item>(from items: [Item], mode: (Item) -> Self) -> [StarChartSection<Item>] {
        allCases.compactMap { chart in
            let matches = items.filter { mode($0) == chart }
            return matches.isEmpty ? nil : StarChartSection(mode: chart, items: matches)
        }
    }
}

struct StarChartSection<Item>: Identifiable {
    let mode: StarChartMode
    let items: [Item]

    var id: StarChartMode { mode }
}

extension MasterySourceModel {
    var starChartMode: StarChartMode {
        uniqueName.hasSuffix(StarChartRules.steelPathSuffix) ? .steelPath : .base
    }
}

extension MissionStat {
    var starChartMode: StarChartMode { tier == StarChartRules.steelPathTier ? .steelPath : .base }
}
struct StarChartRules {
    static let steelPathTier = 1
    static let steelPathSuffix = "#steelPath"
}
