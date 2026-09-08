//
//  WarframeListenerApp.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

@main
struct WarframeListenerApp: App {    
    var body: some Scene {
        WindowGroup {
            MainView()
                .tint(.accent)
                .foregroundStyle(.label)
        }.modelContainer(for: [ProfileDataModel.self, MasteryCatalogDataModel.self])
    }
}
