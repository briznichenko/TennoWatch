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
    @Binding var selectedTab: Int
    @State private var manualMasteryStore: ManualMasteryStore
    @State private var wikiCoordinator = WikiCoordinator()
    @AppStorage(UserDefaultsAccountIDStore.storageKey) private var currentAccountID: String?
    @Environment(\.colorScheme) private var colorScheme

    init(dependencies: AppDependencies, onCacheCleared: @escaping () -> Void, selectedTab: Binding<Int>) {
        self.dependencies = dependencies
        self.onCacheCleared = onCacheCleared
        self._selectedTab = selectedTab
        self._manualMasteryStore = State(initialValue: ManualMasteryStore(
            catalogRepository: dependencies.catalogRepository,
            errorManager: dependencies.errorManager
        ))
    }

    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Strings.Main.tabWorldState, systemImage: "globe.europe.africa", value: 0) {
                WorldStateView(
                    viewModel: .init(
                        worldStateRepository: dependencies.worldStateRepository,
                        voidTraderNotificationScheduler: dependencies.voidTraderNotificationScheduler,
                        errorManager: dependencies.errorManager
                    )
                )
            }
            Tab(Strings.Main.tabMastery, systemImage: "trophy", value: 1) {
                MasteryView(
                    viewModel: .init(
                        profileRepository: dependencies.profileRepository,
                        catalogRepository: dependencies.catalogRepository,
                        errorManager: dependencies.errorManager
                    )
                )
                .id(currentAccountID)
            }
            Tab(Strings.Main.tabOpenings, systemImage: "target", value: 2) {
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
            Tab(Strings.Main.tabProfile, systemImage: "person", value: 3, role: AppPresentation.profileTabRole) {
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
        .environment(manualMasteryStore)
        .appTabStyle()
        .tint(DashboardPalette.accent(in: colorScheme))
        .environment(\.wikiCoordinator, wikiCoordinator)
        .sheet(item: $wikiCoordinator.destination) { destination in
            WikiBrowserView(destination: destination, onClose: wikiCoordinator.dismiss)
        }
    }
}

#Preview {
    let container = try? ModelContainer(for: ProfileDataModel.self, MasteryCatalogDataModel.self, configurations: .init(isStoredInMemoryOnly: true))
    if let container {
        MainView(dependencies: AppDependencies(modelContainer: container), onCacheCleared: {}, selectedTab: .constant(0))
    }
}
