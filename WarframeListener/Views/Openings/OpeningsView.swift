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
            OpeningsListView(viewModel: viewModel)
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
}
