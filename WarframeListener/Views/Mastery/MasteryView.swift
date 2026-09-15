//
//  MasteryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryView: View {
    // MARK: - Object Properties
    @State private var viewModel: MasteryViewModel

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
                        .foregroundStyle(Color.label)
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
            ForEach(viewModel.catalogs) { catalog in
                NavigationLink(destination: MasteryCategoryDetailView(catalogContainer: catalog)) {
                    MasteryCategoryView(catalogContainer: catalog)
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Mastery.categoriesHeader)
        }
    }
    
    @ViewBuilder
    private var otherSourcesList: some View {
        ForEach(viewModel.nonItemSources) { source in
            Section {
                NavigationLink(destination: MasterySourceCategoryDetailView(masteryCategory: source)) {
                    MasterySourceCategoryView(masteryCategory: source)
                }
            } header: {
                SectionHeaderLabel(source.name.sentenceCased)
            }
        }
    }
}
