//
//  MainView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

struct MainView: View {
    // MARK: - Object Properties
    let dependencies: AppDependencies
    let onCacheCleared: () -> Void
    @AppStorage(UserDefaultsAccountIDStore.storageKey) private var currentAccountID: String?

    // MARK: - Body
    var body: some View {
        TabView {
            Tab(Strings.Main.tabWorldState, systemImage: "globe.europe.africa") {
                WorldStateView(
                    viewModel: .init(
                        worldStateRepository: dependencies.worldStateRepository,
                        voidTraderNotificationScheduler: dependencies.voidTraderNotificationScheduler,
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
                .id(currentAccountID)
            }
            Tab(Strings.Main.tabOpenings, systemImage: "target") {
                OpeningsView(
                    viewModel: .init(
                        profileRepository: dependencies.profileRepository,
                        catalogRepository: dependencies.catalogRepository,
                        worldStateRepository: dependencies.worldStateRepository,
                        errorManager: dependencies.errorManager
                    )
                )
                .id(currentAccountID)
            }
            Tab(Strings.Main.tabProfile, systemImage: "person", role: {
                    if #available(anyAppleOS 27.0, *) {
                        .prominent
                    } else { nil }
                }()
            ) {
                ProfileView(
                    viewModel: .init(
                        profileRepository: dependencies.profileRepository,
                        errorManager: dependencies.errorManager
                    ),
                    dependencies: dependencies,
                    onCacheCleared: onCacheCleared
                )
            }
        }
        #if os(macOS)
        .tabViewStyle(.sidebarAdaptable)
        #else
        .toolbarBackground(Color.surface, for: .navigationBar, .tabBar)
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        #endif
    }
}

#Preview {
    let container = try? ModelContainer(for: ProfileDataModel.self, MasteryCatalogDataModel.self, configurations: .init(isStoredInMemoryOnly: true))
    if let container {
        MainView(dependencies: AppDependencies(modelContainer: container), onCacheCleared: {})
    }
}
