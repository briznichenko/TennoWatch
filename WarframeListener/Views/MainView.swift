//
//  MainView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("World state", systemImage: "globe.europe.africa") {
                InvasionsView()
            }
            Tab("Mastery", systemImage: "trophy") {
                MasteryView(
                    viewModel: .init(
                        profileRepository: PersistentProfileRepository(
                            persistencyService: DefaultPersistencyService(
                                modelContainer: modelContext.container
                            )
                        ), catalogRepository: PersistentCatalogRepository(
                            persistencyService: DefaultPersistencyService(
                                modelContainer: modelContext.container
                            )
                        )
                    )
                )
            }
            Tab("Openings", systemImage: "target") {
                Text("Openings will be here")
            }
            Tab("Profile", systemImage: "person") {
                ProfileView(
                    viewModel: .init(
                        profileService: PersistentProfileRepository(
                            persistencyService: DefaultPersistencyService(
                                modelContainer: modelContext.container
                            )
                        )
                    )
                )
            }
        }
    }
}

#Preview {
    MainView()
}
