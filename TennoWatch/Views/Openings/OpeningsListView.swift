//
//  OpeningsListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct OpeningsListView: View {
    // MARK: - Object Properties
    @Bindable var viewModel: OpeningsViewModel
    @State private var isPermanentSectionExpanded: Bool = false

    // MARK: - Body
    var body: some View {
        List {
            timeSensitiveSection
            permanentSection
        }
        .listStyle(.sidebar)
        .searchable(text: $viewModel.searchText, prompt: Strings.Common.search)
    }

    // MARK: - Subviews
    @ViewBuilder
    private var timeSensitiveSection: some View {
        Section {
            if viewModel.timeSensitiveOpenings.isEmpty {
                Text(viewModel.isSearching ? Strings.Common.noSearchResults : Strings.Openings.emptyTimeSensitive)
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
        Section(isExpanded: $isPermanentSectionExpanded) {
            if viewModel.permanentItemCategories.isEmpty && viewModel.permanentSourceCategories.isEmpty {
                Text(viewModel.isSearching ? Strings.Common.noSearchResults : Strings.Openings.emptyPermanent)
                    .foregroundStyle(Color.labelSecondary)
            } else {
                ForEach(viewModel.permanentItemCategories) { summary in
                    NavigationLink {
                        OpeningsItemCategoryDetailView(
                            viewModel: .init(
                                categoryTitle: summary.category.displayName.sentenceCased,
                                items: viewModel.permanentItems(in: summary.category),
                                searchText: viewModel.searchText
                            )
                        )
                    } label: {
                        OpeningsCategoryRowView(title: summary.category.displayName.sentenceCased, countText: summary.countText)
                    }
                }
                ForEach(viewModel.permanentSourceCategories) { summary in
                    NavigationLink {
                        OpeningsSourceCategoryDetailView(
                            viewModel: .init(
                                categoryName: summary.name,
                                sources: viewModel.permanentSources(in: summary.name),
                                searchText: viewModel.searchText
                            )
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
