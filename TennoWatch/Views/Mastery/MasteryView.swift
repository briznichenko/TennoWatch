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
    
    private static let categoryColumns = [GridItem(.flexible()), GridItem(.flexible())]

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
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
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
                case .breakdown:
                    MasteryBreakdownView(viewModel: viewModel)
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
        return Button {
            coordinator.showBreakdown()
        } label: {
            Surface {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(Strings.Mastery.rankBadge(progress.rank))
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(Color.labelPrimary)
                        Spacer()
                        Text("\(progress.currentXP.formatted()) / \(progress.xpForNextRank.formatted())")
                            .font(.caption)
                            .foregroundStyle(Color.labelSecondary)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
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
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
    }

    private var categoryList: some View {
        Section {
            LazyVGrid(columns: Self.categoryColumns, spacing: 12) {
                ForEach(viewModel.categories) { summary in
                    CardView(
                        icon: summary.category.iconName,
                        title: summary.category.displayName.sentenceCased
                    ) {
                        Text(summary.countText)
                    }
                    .onTapGesture {
                        coordinator.showCategoryDetail(summary.category)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .listRowSeparator(.hidden)
        } header: {
            SectionHeaderLabel(Strings.Mastery.categoriesHeader)
        }.listRowBackground(Color.clear)
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
