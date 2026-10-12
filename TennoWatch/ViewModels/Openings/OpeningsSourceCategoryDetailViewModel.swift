import Observation
import Foundation

struct OpeningsNodePlanetGroup: Identifiable {
    let planet: String?
    let sources: [MasterySourceViewModel]

    var id: String? { planet }
}

@Observable
final class OpeningsSourceCategoryDetailViewModel {
    let categoryName: String
    let sources: [MasterySourceViewModel]
    var searchText = ""

    var filteredSources: [MasterySourceViewModel] {
        sources.filter { $0.searchableText.matchesSearch(searchText) }
    }

    var isStarChartCategory: Bool {
        categoryName == MasterySourceType.nodes.rawValue || categoryName == MasterySourceType.junctions.rawValue
    }

    var isNodeCategory: Bool { categoryName == MasterySourceType.nodes.rawValue }

    var starChartSections: [StarChartSection<MasterySourceViewModel>] {
        StarChartMode.sections(from: filteredSources, mode: \.starChartMode)
    }

    var nodePlanetSections: [StarChartSection<OpeningsNodePlanetGroup>] {
        starChartSections.map { section in
            let planets = Dictionary(grouping: section.items, by: \.planet)
                .map { OpeningsNodePlanetGroup(planet: $0.key, sources: $0.value) }
                .sorted {
                    guard let lhs = $0.planet else { return false }
                    guard let rhs = $1.planet else { return true }
                    return lhs.localizedStandardCompare(rhs) == .orderedAscending
                }
            return StarChartSection(mode: section.mode, items: planets)
        }
    }

    init(categoryName: String, sources: [MasterySourceViewModel], searchText: String = "") {
        self.categoryName = categoryName
        self.sources = sources
        self.searchText = searchText
    }
}
