//
//  ProfileView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    // MARK: - Object Properties
    @State private var viewModel: ProfileViewModel
    @State private var isShowingSettings = false
    @Query(sort: \ProfileDataModel.lastUpdated, order: .reverse) private var profiles: [ProfileDataModel]

    private let dependencies: AppDependencies

    private var displayName: String {
        profiles.first?.displayName ?? Strings.Profile.displayNameUnknown
    }

    // MARK: - Init
    init(viewModel: ProfileViewModel, dependencies: AppDependencies) {
        self.viewModel = viewModel
        self.dependencies = dependencies
    }

    // MARK: - Body
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
                Text(displayName)
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
                        catalogRepository: dependencies.catalogRepository,
                        profileRepository: dependencies.profileRepository,
                        errorManager: dependencies.errorManager
                    ),
                    displayName: displayName
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
