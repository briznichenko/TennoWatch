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

    @State private var isShowingSplash = true

    // MARK: - Body
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainView(dependencies: dependencies)
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(1100))
            withAnimation(.easeInOut(duration: 0.35)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    let container = try? ModelContainer(for: ProfileDataModel.self, MasteryCatalogDataModel.self, configurations: .init(isStoredInMemoryOnly: true))
    if let container {
        RootView(dependencies: AppDependencies(modelContainer: container))
    }
}
