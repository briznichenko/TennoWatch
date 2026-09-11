//
//  ProfileView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextField("Player Id", text: $viewModel.playerId).onSubmit {
                    Task {
                        await viewModel.fetchProfile()
                    }
                }
                Text(viewModel.displayName)
                    .font(.title)
                Text(viewModel.networkText)
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .task {
                await viewModel.fetchProfile()
            }.refreshable {
                await viewModel.fetchProfile()
            }
        }
    }
}

#Preview {
//    ProfileView()
}
