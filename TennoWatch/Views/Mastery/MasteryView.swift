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
    @State private var isCategoriesExpanded: Bool = true
    @AppStorage(UserDefaultsAccountIDStore.storageKey) private var currentAccountID: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init
    init(viewModel: MasteryViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: DashboardLayout.sectionSpacing) {
                    summaryCard
                    categoryList
                    otherSourcesList
                }
                .frame(maxWidth: DashboardLayout.maximumContentWidth)
                .padding(DashboardLayout.contentPadding)
                .frame(maxWidth: .infinity)
            }
            .background(Color.bg)
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
            .task(id: currentAccountID) {
                await viewModel.fetchCatalog()
            }
            .platformRefreshable(isDisabled: viewModel.isLoading) {
                await viewModel.fetchCatalog()
            }
        }
    }

    // MARK: - Subviews
    private var summaryCard: some View {
        Button {
            coordinator.showBreakdown()
        } label: {
            MasteryRankCard(
                progress: viewModel.rankProgress,
                itemsRemaining: viewModel.obtainableItemsRemaining
            )
        }
        .buttonStyle(.plain)
    }

    private var categoryList: some View {
        VStack(alignment: .leading, spacing: DashboardLayout.sectionSpacing) {
            Button {
                withAnimation(reduceMotion ? nil : .snappy(duration: Layout.expansionDuration)) {
                    isCategoriesExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(Strings.Mastery.categoriesHeader)
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .rotationEffect(.degrees(isCategoriesExpanded ? 0 : Layout.collapsedChevronAngle))
                }
                .foregroundStyle(Color.labelPrimary)
                .frame(minHeight: ListLayout.minimumRowHeight)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if isCategoriesExpanded {
                LazyVGrid(columns: categoryColumns, spacing: DashboardLayout.gridSpacing) {
                    ForEach(orderedCategories) { summary in
                        Button {
                            coordinator.showCategoryDetail(summary.category)
                        } label: {
                            MasteryCategoryCard(summary: summary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var categoryColumns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : AppPresentation.masteryCategoryColumns
    }

    private var orderedCategories: [CatalogContainerSummary] {
        let primary: [CatalogItemModel.Category] = [.suits, .longGuns, .pistols, .melee]
        let order = primary + CatalogItemModel.Category.allCases.filter { !primary.contains($0) }
        return order.compactMap { category in
            viewModel.categories.first { $0.category == category }
        }
    }

    @ViewBuilder
    private var otherSourcesList: some View {
        ForEach(viewModel.nonItemCategories) { summary in
            NavigationLink(
                value: MasteryCoordinator.Destination
                    .sourceDetail(name: summary.name)
            ) {
                MasterySourceCard(summary: summary)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct Layout {
    static let expansionDuration: TimeInterval = 0.25
    static let collapsedChevronAngle: Double = -90
}
