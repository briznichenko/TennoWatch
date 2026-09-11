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
            Tab("World state", systemImage: "globe.europe.africa") {
                InvasionsView()
            }
            Tab("Mastery", systemImage: "trophy") {
                MasteryView(
                    viewModel: .init(
                        profileRepository: dependencies.profileRepository,
                        catalogRepository: dependencies.catalogRepository
                    )
                )
            }
            Tab("Openings", systemImage: "target") {
                Text("Openings will be here")
            }
            Tab("Profile", systemImage: "person") {
                ProfileView(
                    viewModel: .init(profileService: dependencies.profileRepository),
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
