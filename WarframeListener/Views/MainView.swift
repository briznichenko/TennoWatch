//
//  MainView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

struct MainView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab(Strings.Main.tabWorldState, systemImage: "globe.europe.africa") {
                WorldStateView(
                    viewModel: .init(
                        worldStateRepository: dependencies.worldStateRepository,
                        errorManager: dependencies.errorManager
                    )
                )
            }
            Tab(Strings.Main.tabMastery, systemImage: "trophy") {
                MasteryView(
                    viewModel: .init(
                        profileRepository: dependencies.profileRepository,
                        catalogRepository: dependencies.catalogRepository,
                        errorManager: dependencies.errorManager
                    )
                )
            }
            Tab(Strings.Main.tabOpenings, systemImage: "target") {
                Text(Strings.Main.openingsPlaceholder)
            }
            Tab(Strings.Main.tabProfile, systemImage: "person") {
                ProfileView(
                    viewModel: .init(
                        profileRepository: dependencies.profileRepository,
                        errorManager: dependencies.errorManager
                    ),
                    dependencies: dependencies
                )
            }
        }
        .toolbarBackground(Color.surface, for: .navigationBar, .tabBar)
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
    }
}

#Preview {
    let container = try? ModelContainer(for: ProfileDataModel.self, MasteryCatalogDataModel.self, configurations: .init(isStoredInMemoryOnly: true))
    if let container {
        MainView(dependencies: AppDependencies(modelContainer: container))
    }
}
