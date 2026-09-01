//
//  MainView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab("World state", systemImage: "globe.europe.africa") {
                InvasionsView()
            }
            Tab("Profile", systemImage: "person") {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainView()
}
