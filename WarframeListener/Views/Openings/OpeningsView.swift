//
//  OpeningsView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct OpeningsView: View {
    // MARK: - Object Properties
    @State private var viewModel: OpeningsViewModel

    // MARK: - Init
    init(viewModel: OpeningsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                timeSensitiveSection
                permanentSection
            }
            .navigationTitle(Strings.Openings.title)
            .overlay {
                if viewModel.isLoading && viewModel.catalog == nil {
                    ProgressView()
                }
            }
            .handleErrorAlert(with: viewModel.errorManager)
            .task {
                await viewModel.fetchOpenings()
            }
            .refreshable {
                await viewModel.fetchOpenings()
            }
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
            if viewModel.permanentItems.isEmpty && viewModel.permanentSources.isEmpty {
                Text(Strings.Openings.emptyPermanent)
                    .foregroundStyle(Color.labelSecondary)
            } else {
                ForEach(viewModel.permanentItems) { item in
                    MasteryItemView(viewModel: item)
                }
                ForEach(viewModel.permanentSources) { source in
                    MasterySourceView(viewModel: source)
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Openings.permanentHeader)
        }
    }
}
