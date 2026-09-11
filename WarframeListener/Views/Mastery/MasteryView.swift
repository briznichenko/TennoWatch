//
//  MasteryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryView: View {
    @State private var viewModel: MasteryViewModel

    init(viewModel: MasteryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                summaryCard
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

                categoryList
            }
            .listStyle(.plain)
            .themedList()
            .navigationTitle("Mastery")
            .task {
                await viewModel.fetchCatalog()
            }
            .refreshable {
                await viewModel.fetchProfile()
            }
        }
    }

    private var summaryCard: some View {
        let progress = viewModel.rankProgress
        return Surface {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text("MR \(progress.rank)")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color.label)
                    Spacer()
                    Text("\(progress.currentXP.formatted()) / \(progress.xpForNextRank.formatted())")
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                ProgressBar(value: progress.fraction)
                    .padding(.vertical, 4)
                let xpLine = "\(progress.xpToNextRank.formatted()) XP to MR \(progress.rank + 1)"
                let itemsLine = "\(viewModel.obtainableItemsRemaining) items left"
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
            SectionHeaderLabel("Categories")
        }
    }
}
