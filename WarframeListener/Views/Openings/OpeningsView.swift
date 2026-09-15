//
//  OpeningsView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct OpeningsView: View {
    @State private var viewModel: OpeningsViewModel
    
    var body: some View {
        List {
            Section("Time-sensitive") {
                Text("Time-sensitive openings will be here")
            }
            Section("Permamnent") {
                Text("Permanent openings will be here")
            }
        }
    }
}
