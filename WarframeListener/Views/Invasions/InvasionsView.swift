//
//  InvasionsView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct InvasionsView: View {
    @State private var viewModel = InvasionsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.invasions) { invasion in
                    InvasionView(invasion: invasion)
                }
            }
            .navigationTitle(Strings.Invasions.title)
            .overlay {
                if viewModel.isLoading && viewModel.invasions.isEmpty {
                    Text(viewModel.networkMessage)
                    ProgressView()
                }
            }
        }
        .task {
            await viewModel.fetchInvasions()
        }.refreshable {
            await viewModel.fetchInvasions()
        }
    }
}

#Preview {
    InvasionsView()
}
