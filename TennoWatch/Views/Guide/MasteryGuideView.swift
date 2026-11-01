import SwiftUI

struct MasteryGuideView: View {
    @State var viewModel: MasteryGuideViewModel

    var body: some View {
        Form {
            Section {
                Text(Strings.Guide.intro)
                if !viewModel.hasRemoteProfile {
                    Text(Strings.Guide.localProfile).foregroundStyle(.secondary)
                }
                Picker(Strings.Guide.category, selection: $viewModel.category) {
                    Text(Strings.Guide.allCategories).tag(nil as CatalogItemModel.Category?)
                    ForEach(CatalogItemModel.Category.allCases, id: \.self) { category in
                        Text(category.displayName.capitalized).tag(Optional(category))
                    }
                }
                Toggle(Strings.Guide.marketOnly, isOn: $viewModel.knownBlueprintPriceOnly)
                TextField(Strings.Guide.search, text: $viewModel.search)
            }
            Section(Strings.Guide.shortlist) {
                Text(Strings.Guide.ranking).font(.caption).foregroundStyle(.secondary)
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.candidates.isEmpty {
                    Text(Strings.Guide.noResults)
                }
                ForEach(viewModel.candidates.prefix(5)) { candidate in
                    candidateView(candidate)
                }
            }
            Section(Strings.Guide.assistant) {
                Text(Strings.Guide.modelDetails).font(.caption).foregroundStyle(.secondary)
                if !MLXLocalGuideService.isSupported {
                    Text(Strings.Guide.unsupported)
                } else if viewModel.isWorking {
                    if !viewModel.isModelReady {
                        ProgressView(value: viewModel.progress) {
                            Text(Strings.Guide.downloading)
                        }
                    } else {
                        ProgressView(Strings.Guide.generating)
                    }
                    Button(Strings.Guide.cancel, action: viewModel.cancel)
                } else if !viewModel.isModelReady {
                    Button(Strings.Guide.download, action: viewModel.prepareModel)
                } else {
                    Button(Strings.Guide.explainPlan) { viewModel.explain() }
                        .disabled(viewModel.candidates.isEmpty)
                }
                if let message = viewModel.message {
                    Text(message).foregroundStyle(.secondary)
                }
                if !viewModel.response.isEmpty {
                    if let id = viewModel.explainedItemID,
                       let candidate = viewModel.candidates.first(where: { $0.id == id }) {
                        Text(candidate.name).font(.headline)
                    }
                    Text(viewModel.response).textSelection(.enabled)
                    Text(Strings.Guide.generatedWarning).font(.caption).foregroundStyle(.secondary)
                }
            }
            if let snapshot = viewModel.snapshot {
                Section(Strings.Guide.sources) {
                    Text(Strings.Guide.snapshot(snapshot.snapshotDate))
                    Link(Strings.Guide.sourceLink, destination: snapshot.source)
                    Text(Strings.Guide.sourceWarning).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Strings.Guide.title)
        .task { await viewModel.load() }
        .onDisappear { viewModel.cancel() }
        .onChange(of: viewModel.category) { viewModel.clearExplanation() }
        .onChange(of: viewModel.knownBlueprintPriceOnly) { viewModel.clearExplanation() }
        .onChange(of: viewModel.search) { viewModel.clearExplanation() }
    }

    private func candidateView(_ candidate: GuideCandidate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(candidate.name).font(.headline)
            Text(Strings.Guide.progress(candidate.item.rank, candidate.item.catalogItemModel.maxRank, candidate.item.remainingMasteryPoints))
                .font(.caption).foregroundStyle(.secondary)
            if let facts = candidate.acquisition {
                if let required = facts.masteryRequirement {
                    Text(Strings.Guide.requiredRank(required))
                }
                if let credits = facts.blueprintCredits {
                    Text(Strings.Guide.blueprintCost(credits))
                }
                if let credits = facts.buildCredits {
                    Text(Strings.Guide.buildCost(credits))
                }
                if !facts.components.isEmpty {
                    DisclosureGroup(Strings.Guide.components) {
                        ForEach(Array(facts.components.enumerated()), id: \.offset) { _, component in
                            VStack(alignment: .leading) {
                                Text("\(component.count) × \(component.name)")
                                ForEach(component.locations.prefix(5), id: \.self) { location in
                                    Text(location).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                ForEach(Array(facts.locations.prefix(5)), id: \.self) { location in
                    Text(location).font(.caption)
                }
                if facts.locations.isEmpty && facts.blueprintCredits == nil {
                    Text(Strings.Guide.unknownAcquisition).font(.caption).foregroundStyle(.secondary)
                }
            } else {
                Text(Strings.Guide.unknownAcquisition).font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                ItemWikiLink(itemName: candidate.name)
                Spacer()
                if viewModel.isModelReady {
                    Button(Strings.Guide.explainItem) { viewModel.explain(candidate) }
                        .disabled(viewModel.isWorking)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
