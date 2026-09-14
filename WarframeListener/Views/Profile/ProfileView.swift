//
//  ProfileView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isShowingSettings = false

    private let dependencies: AppDependencies

    init(viewModel: ProfileViewModel, dependencies: AppDependencies) {
        self.viewModel = viewModel
        self.dependencies = dependencies
    }

    // TODO: - Deconstruct;
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                LabeledContent(Strings.Profile.id) {
                    TextField(Strings.Profile.idPlaceholder, text: $viewModel.playerId)
                }
                .foregroundStyle(Color.label)
                .onSubmit {
                    Task {
                        await viewModel.fetchProfile()
                    }
                }
                Text(viewModel.displayName)
                    .font(.title)
                    .foregroundStyle(Color.label)
                Spacer()
            }
            .padding()
            .screenBackground()
            .navigationTitle(Strings.Profile.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .handleErrorAlert(with: viewModel.errorManager)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(
                    viewModel: .init(
                        persistencyService: dependencies.persistencyService,
                        catalogRepository: dependencies.catalogRepository,
                        profileRepository: dependencies.profileRepository,
                        errorManager: dependencies.errorManager
                    ),
                    displayName: viewModel.displayName
                )
            }
            .task {
                await viewModel.fetchProfile()
            }
            .refreshable {
                await viewModel.fetchProfile()
            }
        }
    }
}
