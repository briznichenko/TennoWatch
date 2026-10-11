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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    var body: some View {
        let openings = viewModel.timeSensitiveOpenings
        let itemCategories = viewModel.permanentItemCategories
        let sourceCategories = viewModel.permanentSourceCategories
        List {
            if viewModel.catalog != nil {
                summaryCard(
                    timeSensitiveCount: openings.count,
                    permanentCount: itemCategories.reduce(0) { $0 + $1.count }
                        + sourceCategories.reduce(0) { $0 + $1.count }
                )
                .listRowInsets(Layout.heroInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            timeSensitiveSection(openings: openings)
            permanentSection(itemCategories: itemCategories, sourceCategories: sourceCategories)
        }
        .listStyle(.sidebar)
        .compactListSections()
        .scrollContentBackground(.hidden)
        .background(Color.bg)
        .searchable(text: $viewModel.searchText, prompt: Strings.Common.search)
    }

    // MARK: - Subviews
    @ViewBuilder
    private func timeSensitiveSection(openings: [TimeSensitiveOpeningViewModel]) -> some View {
        Section {
            if openings.isEmpty {
                Text(viewModel.isSearching ? Strings.Common.noSearchResults : Strings.Openings.emptyTimeSensitive)
                    .foregroundStyle(Color.labelSecondary)
                    .padding(.vertical, Layout.emptyStatePadding)
            } else {
                ForEach(openings) { opening in
                    TimeSensitiveOpeningRowView(viewModel: opening)
                }
            }
        } header: {
            DashboardSectionHeader(title: Strings.Openings.timeSensitiveHeader, icon: "bolt.fill")
        }
        .listRowInsets(Layout.heroInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func permanentSection(
        itemCategories: [OpeningsItemCategorySummary],
        sourceCategories: [OpeningsSourceCategorySummary]
    ) -> some View {
        Section(isExpanded: $isPermanentSectionExpanded) {
            if itemCategories.isEmpty && sourceCategories.isEmpty {
                Text(viewModel.isSearching ? Strings.Common.noSearchResults : Strings.Openings.emptyPermanent)
                    .foregroundStyle(Color.labelSecondary)
            } else {
                ForEach(itemCategories) { summary in
                    NavigationLink {
                        OpeningsItemCategoryDetailView(
                            viewModel: .init(
                                categoryTitle: summary.category.displayName.sentenceCased,
                                items: viewModel.permanentItems(in: summary.category),
                                searchText: viewModel.searchText
                            )
                        )
                    } label: {
                        OpeningsCategoryRowView(
                            title: summary.category.displayName.sentenceCased,
                            countText: summary.countText,
                            icon: summary.category.iconName
                        )
                    }
                }
                ForEach(sourceCategories) { summary in
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
            DashboardSectionHeader(title: Strings.Openings.permanentHeader, icon: "square.stack.3d.up")
        }
        .listRowBackground(Color.surface)
        .listRowSeparatorTint(Color.divider)
    }

    private func summaryCard(timeSensitiveCount: Int, permanentCount: Int) -> some View {
        DashboardHero(title: Strings.Openings.title, icon: "target") {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: Layout.accessibilityMetricSpacing))
                : AnyLayout(HStackLayout(alignment: .top, spacing: Layout.metricSpacing))
            layout {
                DashboardMetric(value: timeSensitiveCount.formatted(), title: Strings.Openings.timeSensitiveHeader)
                DashboardMetric(value: permanentCount.formatted(), title: Strings.Openings.permanentHeader)
            }
        }
    }
}

private struct Layout {
    static let heroInsets = EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
    static let emptyStatePadding: CGFloat = 12
    static let accessibilityMetricSpacing: CGFloat = 12
    static let metricSpacing: CGFloat = 16
}
