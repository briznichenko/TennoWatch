import Observation

@Observable
final class OpeningsSourceCategoryDetailViewModel {
    let categoryName: String
    let sources: [MasterySourceViewModel]
    var searchText = ""

    var filteredSources: [MasterySourceViewModel] {
        sources.filter { $0.name.matchesSearch(searchText) || $0.uniqueName.matchesSearch(searchText) }
    }

    var isStarChartCategory: Bool {
        categoryName == MasterySourceType.nodes.rawValue || categoryName == MasterySourceType.junctions.rawValue
    }

    var starChartSections: [StarChartSection<MasterySourceViewModel>] {
        StarChartMode.sections(from: filteredSources, mode: \.starChartMode)
    }

    init(categoryName: String, sources: [MasterySourceViewModel], searchText: String = "") {
        self.categoryName = categoryName
        self.sources = sources
        self.searchText = searchText
    }
}
