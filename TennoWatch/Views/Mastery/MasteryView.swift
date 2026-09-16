//
//  MasteryView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryView: View {
    // MARK: - Object Properties
    @State private var viewModel: MasteryViewModel
    @State private var coordinator = MasteryCoordinator()

    // MARK: - Init
    init(viewModel: MasteryViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
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
                    LotusLoaderView()
                }
            }
            .handleErrorAlert(with: viewModel.errorManager)
            .navigationDestination(
                for: MasteryCoordinator.Destination.self
            ) { destination in
                switch destination {
                case .categoryDetail(let category):
                    let detailViewModel = viewModel
                        .makeCategoryDetailViewModel(for: category)
                    MasteryCategoryDetailView(viewModel: detailViewModel)
                case .sourceDetail(let name):
                    let detailViewModel = viewModel
                        .makeSourceDetailViewModel(for: name)
                    MasterySourceCategoryDetailView(viewModel: detailViewModel)
                }
            }
            .task {
                await viewModel.fetchCatalog()
            }
            .refreshable {
                await viewModel.fetchCatalog(forceRefresh: true)
            }
        }
    }

    // MARK: - Subviews
    private var summaryCard: some View {
        let progress = viewModel.rankProgress
        return Surface {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(Strings.Mastery.rankBadge(progress.rank))
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color.labelPrimary)
                    Spacer()
                    Text("\(progress.currentXP.formatted()) / \(progress.xpForNextRank.formatted())")
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                ProgressBar(value: progress.fraction)
                    .padding(.vertical, 4)
                let xpLine = Strings.Mastery.xpToNextRank(progress.xpToNextRank.formatted(), nextRank: progress.rank + 1)
                let itemsLine = Strings.Mastery.itemsLeft(viewModel.obtainableItemsRemaining)
                Text("\(xpLine) · \(itemsLine)")
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .padding(.bottom, 8)
    }

    private var categoryList: some View {
        Section {
            ForEach(viewModel.categories) { summary in
                NavigationLink(
                    value: MasteryCoordinator.Destination
                        .categoryDetail(summary.category)
                ) {
                    MasteryCategoryView(summary: summary)
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Mastery.categoriesHeader)
        }
    }

    @ViewBuilder
    private var otherSourcesList: some View {
        ForEach(viewModel.nonItemCategories) { summary in
            Section {
                NavigationLink(
                    value: MasteryCoordinator.Destination
                        .sourceDetail(name: summary.name)
                ) {
                    MasterySourceCategoryView(summary: summary)
                }
            } header: {
                SectionHeaderLabel(summary.name.sentenceCased)
            }
        }
    }
}
