//
//  AppSettingsButton.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/7/26.
//

import SwiftUI

struct AppSettingsButton: View {
    @Binding var isPresented: Bool

    var body: some View {
        #if os(macOS)
        SettingsLink {
            Label(Strings.Settings.title, systemImage: "gearshape")
        }
        #else
        Button {
            isPresented = true
        } label: {
            Image(systemName: "gearshape")
        }
        #endif
    }
}
