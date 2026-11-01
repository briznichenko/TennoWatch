import Foundation

struct GuideAcquisitionSnapshot: Decodable, Sendable {
    let source: URL
    let snapshotDate: String
    let items: [String: GuideAcquisition]

    static func load() throws -> Self {
        guard let url = Bundle.main.url(forResource: "guide-acquisition", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
    }
}

struct GuideAcquisition: Decodable, Sendable {
    struct Component: Decodable, Sendable {
        let name: String
        let count: Int
        let locations: [String]
    }

    let masteryRequirement: Int?
    let blueprintCredits: Int?
    let buildCredits: Int?
    let buildSeconds: Int?
    let components: [Component]
    let locations: [String]
}

struct GuideCandidate: Identifiable, Sendable {
    let item: MasteryItem
    let acquisition: GuideAcquisition?

    var id: String { item.catalogItemModel.uniqueName }
    var name: String { item.catalogItemModel.name }
}

struct MasteryGuidePlanner: Sendable {
    func candidates(
        catalog: MasteryCatalog,
        acquisition: GuideAcquisitionSnapshot,
        category: CatalogItemModel.Category?,
        rank: Int?,
        knownBlueprintPriceOnly: Bool,
        search: String
    ) -> [GuideCandidate] {
        catalog.items
            .filter { category == nil || $0.category == category }
            .flatMap(\.masteryItems)
            .filter { item in
                guard item.obtainable, !item.isMastered else { return false }
                let facts = acquisition.items[item.catalogItemModel.uniqueName]
                if let rank, let required = facts?.masteryRequirement, required > rank { return false }
                if knownBlueprintPriceOnly && facts?.blueprintCredits == nil { return false }
                return search.isEmpty || item.catalogItemModel.name.localizedStandardContains(search)
            }
            .map { GuideCandidate(item: $0, acquisition: acquisition.items[$0.catalogItemModel.uniqueName]) }
            .sorted { left, right in
                if (left.item.rank > 0) != (right.item.rank > 0) { return left.item.rank > 0 }
                if left.item.remainingMasteryPoints != right.item.remainingMasteryPoints {
                    return left.item.remainingMasteryPoints > right.item.remainingMasteryPoints
                }
                return left.id < right.id
            }
    }

    func context(for candidates: [GuideCandidate], snapshotDate: String) -> String {
        let records = candidates.prefix(5).map { candidate in
            let item = candidate.item
            var facts = [
                "Item: \(candidate.name)",
                "Category: \(item.catalogItemModel.category.displayName)",
                "Rank: \(item.rank)/\(item.catalogItemModel.maxRank)",
                "Remaining mastery XP: \(item.remainingMasteryPoints)",
                "Requires gilding: \(item.catalogItemModel.requiresGilding)"
            ]
            if let acquisition = candidate.acquisition {
                if let rank = acquisition.masteryRequirement { facts.append("Required mastery rank: \(rank)") }
                if let cost = acquisition.blueprintCredits { facts.append("Blueprint price (vendor unspecified): \(cost) credits") }
                if let cost = acquisition.buildCredits { facts.append("Build cost: \(cost) credits") }
                if let seconds = acquisition.buildSeconds { facts.append("Build duration: \(seconds) seconds") }
                if acquisition.locations.isEmpty {
                    facts.append("Acquisition route: UNKNOWN. Check the linked wiki. A component or blueprint requirement is not an acquisition source.")
                } else {
                    facts.append("Recorded acquisition locations: \(acquisition.locations.prefix(6).joined(separator: "; "))")
                }
                for component in acquisition.components.prefix(12) {
                    facts.append("Component: \(component.count) x \(component.name); recorded sources: \(component.locations.prefix(4).joined(separator: "; "))")
                }
            } else {
                facts.append("Acquisition details unknown. Consult the linked wiki.")
            }
            return facts.joined(separator: "\n")
        }
        return "WFCD acquisition snapshot: \(snapshotDate). Sources can be outdated; current availability is unknown.\n"
            + records.joined(separator: "\n\n")
    }
}
