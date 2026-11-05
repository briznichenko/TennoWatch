//
//  RootView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    // MARK: - Object Properties
    let dependencies: AppDependencies

    @State private var selectedTab = 0
    @State private var isShowingSplash = true
    @State private var cacheResetID = UUID()

    // MARK: - Body
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainView(dependencies: dependencies, onCacheCleared: {
                    cacheResetID = UUID()
                }, selectedTab: $selectedTab)
                .id(cacheResetID)
                .transition(.opacity)
            }
        }
        .onOpenURL { url in
            guard url.scheme == "tennowatch" else { return }
            switch url.host {
            case "world-state": selectedTab = 0
            case "mastery": selectedTab = 1
            default: break
            }
        }
        .task {
            try? await dependencies.catalogRepository.prepareCatalog()
            withAnimation(.easeInOut(duration: AnimationTiming.splashTransition)) {
                isShowingSplash = false
            }
        }
    }
}

private struct AnimationTiming {
    static let splashTransition: TimeInterval = 0.35
}

#Preview {
    let container = try? ModelContainer(for: ProfileDataModel.self, MasteryCatalogDataModel.self, configurations: .init(isStoredInMemoryOnly: true))
    if let container {
        RootView(dependencies: AppDependencies(modelContainer: container))
    }
}
