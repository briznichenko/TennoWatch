//
//  OpeningsListView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct OpeningsListView: View {
    // MARK: - Object Properties
    let viewModel: OpeningsViewModel

    // MARK: - Body
    var body: some View {
        List {
            timeSensitiveSection
            permanentSection
        }
    }

    // MARK: - Subviews
    @ViewBuilder
    private var timeSensitiveSection: some View {
        Section {
            if viewModel.timeSensitiveOpenings.isEmpty {
                Text(Strings.Openings.emptyTimeSensitive)
                    .foregroundStyle(Color.labelSecondary)
            } else {
                ForEach(viewModel.timeSensitiveOpenings) { opening in
                    TimeSensitiveOpeningRowView(viewModel: opening)
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Openings.timeSensitiveHeader)
        }
    }

    @ViewBuilder
    private var permanentSection: some View {
        Section {
            if viewModel.permanentItemCategories.isEmpty && viewModel.permanentSourceCategories.isEmpty {
                Text(Strings.Openings.emptyPermanent)
                    .foregroundStyle(Color.labelSecondary)
            } else {
                ForEach(viewModel.permanentItemCategories) { summary in
                    NavigationLink {
                        OpeningsItemCategoryDetailView(
                            categoryTitle: summary.category.displayName.sentenceCased,
                            items: viewModel.permanentItems(in: summary.category)
                        )
                    } label: {
                        OpeningsCategoryRowView(title: summary.category.displayName.sentenceCased, countText: summary.countText)
                    }
                }
                ForEach(viewModel.permanentSourceCategories) { summary in
                    NavigationLink {
                        OpeningsSourceCategoryDetailView(
                            categoryTitle: summary.name.sentenceCased,
                            sources: viewModel.permanentSources(in: summary.name)
                        )
                    } label: {
                        OpeningsCategoryRowView(title: summary.name.sentenceCased, countText: summary.countText)
                    }
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Openings.permanentHeader)
        }
    }
}
