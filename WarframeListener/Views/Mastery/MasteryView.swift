//
//  MasteryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI
import SwiftData

struct MasteryView: View {
    // MARK: - Object Properties
    @State private var viewModel: MasteryViewModel
    @Query(sort: \MasteryCatalogDataModel.generatedAt, order: .reverse) private var catalogs: [MasteryCatalogDataModel]

    private var catalog: MasteryCatalogDataModel? { catalogs.first }

    // MARK: - Init
    init(viewModel: MasteryViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                summaryCard
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                categoryList
                otherSourcesList
            }
            .navigationTitle(Strings.Mastery.title)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .handleErrorAlert(with: viewModel.errorManager)
            .task {
                await viewModel.fetchCatalog()
            }
            .refreshable {
                await viewModel.fetchCatalog()
            }
        }
    }

    // MARK: - Subviews
    private var summaryCard: some View {
        let progress = viewModel.summary?.rankProgress ?? .rankProgress(forXP: 0)
        return Surface {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(Strings.Mastery.rankBadge(progress.rank))
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color.label)
                    Spacer()
                    Text("\(progress.currentXP.formatted()) / \(progress.xpForNextRank.formatted())")
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                ProgressBar(value: progress.fraction)
                    .padding(.vertical, 4)
                let xpLine = Strings.Mastery.xpToNextRank(progress.xpToNextRank.formatted(), nextRank: progress.rank + 1)
                let itemsLine = Strings.Mastery.itemsLeft(viewModel.summary?.obtainableItemsRemaining ?? 0)
                Text("\(xpLine) · \(itemsLine)")
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .padding(.bottom, 8)
    }

    private var categoryList: some View {
        let sortedContainers = (catalog?.items ?? []).sorted { $0.category.displayName < $1.category.displayName }
        return Section {
            ForEach(sortedContainers) { container in
                NavigationLink(
                    destination: MasteryCategoryDetailView(
                        catalogContainer: container,
                        itemSnapshots: viewModel.summary?.itemSnapshots ?? [:]
                    )
                ) {
                    MasteryCategoryView(
                        catalogContainer: container,
                        countOverride: viewModel.summary?.itemCategoryCounts[container.category]
                    )
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Mastery.categoriesHeader)
        }
    }

    @ViewBuilder
    private var otherSourcesList: some View {
        ForEach(catalog?.nonItemSources ?? []) { source in
            Section {
                NavigationLink(
                    destination: MasterySourceCategoryDetailView(
                        masteryCategory: source,
                        sourceSnapshots: viewModel.summary?.sourceSnapshots ?? [:]
                    )
                ) {
                    MasterySourceCategoryView(
                        masteryCategory: source,
                        countOverride: viewModel.summary?.sourceCategoryCounts[source.name]
                    )
                }
            } header: {
                SectionHeaderLabel(source.name.sentenceCased)
            }
        }
    }
}
