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
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                ForEach(viewModel.invasions) { invasion in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invasion.node)
                            .font(.headline)
                        Text(invasion.desc)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let reward = invasion.attacker.reward {
                            InvasionView(reward: reward)
                        }
                        if let reward = invasion.defender.reward { InvasionView(reward: reward)
                        }
                    }
                }
            }
            .navigationTitle("Invasions")
            .overlay {
                if viewModel.isLoading && viewModel.invasions.isEmpty {
                    ProgressView()
                }
            }
        }
        .task {
            viewModel.fetchInvasions()
        }
    }
}

#Preview {
    InvasionsView()
}
