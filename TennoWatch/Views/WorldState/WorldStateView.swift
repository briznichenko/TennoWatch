//
//  WorldStateView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct WorldStateView: View {
    // MARK: - Object Properties
    @State private var viewModel: WorldStateViewModel

    // MARK: - Init
    init(viewModel: WorldStateViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            WorldStateListView(viewModel: viewModel)
                .navigationTitle(Strings.WorldState.title)
                .overlay {
                    if viewModel.isLoading && viewModel.worldState == nil {
                        LotusLoaderView()
                    }
                }
                .handleErrorAlert(with: viewModel.errorManager)
                .task {
                    await viewModel.fetchWorldState()
                }
                .refreshable {
                    await viewModel.fetchWorldState()
                }
        }
    }
}

#Preview {
    WorldStateView(
        viewModel: .init(
            worldStateRepository: DefaultWorldStateRepository(),
            errorManager: DefaultErrorManager()
        )
    )
}
