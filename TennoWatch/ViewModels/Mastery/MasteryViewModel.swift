//
//  MasteryViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

struct MasteryRankProgress {
    let rank: Int
    let currentXP: Int
    let xpForCurrentRank: Int
    let xpForNextRank: Int

    var fraction: Double {
        let span = Double(xpForNextRank - xpForCurrentRank)
        guard span > 0 else { return 1 }
        return Double(currentXP - xpForCurrentRank) / span
    }

    var xpToNextRank: Int { xpForNextRank - currentXP }
}

@Observable
final class MasteryViewModel {
    // MARK: - Object Properties
    private let profileRepository: ProfileRepository
    private let catalogRepository: CatalogRepository
    private let categoryContainerCache: CategoryContainerCache
    let errorManager: ErrorManager

    private(set) var summary: MasteryCatalogSummary?

    private(set) var isLoading: Bool = false

    // Not structured under `fetchCatalog()`'s Task, so cancelling/awaiting that fetch
    // has no effect on this — see `prefetchCategoryContainers()` for why that's the point.
    private var prefetchTask: Task<Void, Never>?

    // MARK: - Computed Properties
    var categories: [CatalogContainerSummary] {
        summary?.categories ?? []
    }
    var nonItemCategories: [MasteryCategorySummary] {
        summary?.nonItemCategories ?? []
    }

    var earnedMasteryXP: Int {
        categories.reduce(0) { $0 + $1.earnedMasteryPoints }
            + nonItemCategories.reduce(0) { $0 + $1.earnedMasteryPoints }
    }

    var rankProgress: MasteryRankProgress {
        Self.rankProgress(forXP: earnedMasteryXP)
    }

    var obtainableItemsRemaining: Int {
        categories.reduce(0) { $0 + $1.obtainableRemainingCount }
    }

    // MARK: - Init
    init(
        profileRepository: ProfileRepository,
        catalogRepository: CatalogRepository,
        categoryContainerCache: CategoryContainerCache,
        errorManager: ErrorManager
    ) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.categoryContainerCache = categoryContainerCache
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchCatalog(forceRefresh: Bool = false) async {
        isLoading = summary == nil
        defer {
            isLoading = false
        }

        do {
            if let profile = try? await profileRepository.getProfile(forceRefresh: forceRefresh) {
                summary = try await catalogRepository.syncMasterySummary(with: profile)
            } else {
                summary = try await catalogRepository.getMasterySummary()
            }
            prefetchCategoryContainers()
        } catch {
            errorManager.append(error)
        }
    }

    func makeCategoryDetailViewModel(for category: CatalogItemModel.Category) -> MasteryCategoryDetailViewModel {
        .init(
            category: category,
            catalogRepository: catalogRepository,
            categoryContainerCache: categoryContainerCache,
            errorManager: errorManager
        )
    }

    func makeSourceDetailViewModel(for categoryName: String) -> MasterySourceCategoryDetailViewModel {
        .init(categoryName: categoryName, catalogRepository: catalogRepository, errorManager: errorManager)
    }

    // MARK: - Helper Functions

    // Warms `categoryContainerCache` for every category right after the summary loads, so
    // tapping into a category is usually an instant cache hit instead of a fresh fetch.
    //
    // Why `Task.detached` and not a plain `Task { }`: a plain `Task` inherits the calling
    // context's priority and — if it were created under a parent task's scope — its
    // cancellation. Neither inheritance is wanted here. This work is triggered by a
    // MainActor screen load, but it's genuinely lower priority than the UI, and it
    // shouldn't be torn down just because the *triggering* `fetchCatalog()` call gets
    // cancelled (e.g. the user leaves the tab before the summary finishes). A detached
    // Task is unstructured — nothing owns it, so nothing accidentally cancels it. The
    // trade-off is real cost, not free: nothing about the type system stops it from
    // outliving `self`, which is exactly why every capture below is explicit and
    // `self` itself is never captured.
    //
    // Why `withTaskGroup` and not `async let`: the branch count is
    // `CatalogItemModel.Category.allCases.count` — a number the compiler doesn't know
    // ahead of time. `async let` needs each concurrent child spelled out by hand, which
    // only works for a small, fixed arity (compare `OpeningsViewModel.fetchOpenings()`,
    // where exactly two children really is the right, simpler tool). TaskGroup is the
    // one that scales to "however many categories exist today."
    private func prefetchCategoryContainers() {
        prefetchTask?.cancel()
        prefetchTask = Task.detached(priority: .background) { [catalogRepository, categoryContainerCache] in
            await withTaskGroup(of: (CatalogItemModel.Category, CatalogContainer?).self) { group in
                for category in CatalogItemModel.Category.allCases {
                    group.addTask {
                        // Best-effort: a failure here just means that category falls back
                        // to its normal on-demand fetch later. Nobody is waiting on this
                        // result right now, so there's no user-facing error to raise.
                        let container = try? await catalogRepository.getCatalogContainer(for: category)
                        return (category, container)
                    }
                }
                for await (category, container) in group {
                    guard let container, !Task.isCancelled else { continue }
                    await categoryContainerCache.store(container, for: category)
                }
            }
        }
    }

    private static func rankProgress(forXP xp: Int) -> MasteryRankProgress {
        func cumulativeXP(for rank: Int) -> Int { 2500 * rank * (rank + 1) }
        var completedRanks = 0
        while cumulativeXP(for: completedRanks + 1) <= xp {
            completedRanks += 1
        }
        return MasteryRankProgress(
            rank: completedRanks + 1,
            currentXP: xp,
            xpForCurrentRank: cumulativeXP(for: completedRanks),
            xpForNextRank: cumulativeXP(for: completedRanks + 1)
        )
    }

}
