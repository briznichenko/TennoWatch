import Foundation
import Observation

@Observable
@MainActor
final class MasteryGuideViewModel {
    var category: CatalogItemModel.Category?
    var knownBlueprintPriceOnly = false
    var search = ""
    private(set) var isLoading = false
    private(set) var isWorking = false
    private(set) var isModelReady = false
    private(set) var progress: Double = 0
    private(set) var response = ""
    private(set) var message: String?
    private(set) var explainedItemID: String?
    private(set) var snapshot: GuideAcquisitionSnapshot?
    private(set) var hasRemoteProfile = false

    private let catalogRepository: CatalogRepository
    private let profileRepository: ProfileRepository
    private let service: LocalGuideService
    private var catalog: MasteryCatalog?
    private var rank: Int?
    private var operation: Task<Void, Never>?
    private var requestID = UUID()
    private let planner = MasteryGuidePlanner()

    var candidates: [GuideCandidate] {
        guard let catalog, let snapshot else { return [] }
        return planner.candidates(
            catalog: catalog, acquisition: snapshot, category: category, rank: rank,
            knownBlueprintPriceOnly: knownBlueprintPriceOnly,
            search: search.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    init(catalogRepository: CatalogRepository, profileRepository: ProfileRepository, service: LocalGuideService) {
        self.catalogRepository = catalogRepository
        self.profileRepository = profileRepository
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        message = nil
        do {
            let accountID = await profileRepository.currentAccountID
            let profiles = try await profileRepository.getSavedProfiles()
            let profile = profiles.first { $0.accountID.oid == accountID }
            let loaded = try await catalogRepository.getMasteryCatalog()
            let acquisition = try GuideAcquisitionSnapshot.load()
            try Task.checkCancellation()
            catalog = loaded
            snapshot = acquisition
            hasRemoteProfile = profile.map { !$0.isLocal } ?? false
            rank = profile.flatMap { $0.isLocal ? nil : $0.playerLevel }
        } catch {
            if !Task.isCancelled { message = Strings.Guide.catalogError }
        }
    }

    func prepareModel() {
        start { [self] id in
            try await service.prepare { [weak self] fraction in
                await self?.setProgress(fraction, id: id)
            }
            guard requestID == id else { return }
            isModelReady = true
        }
    }

    func explain(_ candidate: GuideCandidate? = nil) {
        guard let snapshot else { return }
        let selected = candidate.map { [$0] } ?? Array(candidates.prefix(5))
        guard !selected.isEmpty else { return }
        let context = planner.context(for: selected, snapshotDate: snapshot.snapshotDate)
        start { [self] id in
            explainedItemID = candidate?.id
            try await service.explain(context: context, itemOnly: candidate != nil) { [weak self] text in
                await self?.setResponse(text, id: id)
            }
        }
    }

    func cancel() {
        operation?.cancel()
        requestID = UUID()
        isWorking = false
    }

    func clearExplanation() {
        cancel()
        response = ""
        explainedItemID = nil
    }

    private func start(_ action: @escaping @MainActor (UUID) async throws -> Void) {
        guard !isWorking else { return }
        let id = UUID()
        requestID = id
        isWorking = true
        response = ""
        message = nil
        progress = 0
        operation = Task { [weak self] in
            do {
                try Task.checkCancellation()
                try await action(id)
            } catch {
                guard let self, self.requestID == id, !Task.isCancelled else { return }
                switch error {
                case GuideError.unsupported: self.message = Strings.Guide.unsupported
                case GuideError.busy: self.message = Strings.Guide.busy
                default: self.message = self.isModelReady ? Strings.Guide.generationError : Strings.Guide.downloadError
                }
            }
            guard let self, self.requestID == id else { return }
            self.isWorking = false
            self.operation = nil
        }
    }

    private func setProgress(_ value: Double, id: UUID) {
        guard requestID == id, isWorking else { return }
        progress = max(progress, min(1, max(0, value)))
    }

    private func setResponse(_ text: String, id: UUID) {
        guard requestID == id, isWorking else { return }
        response = text
    }
}
