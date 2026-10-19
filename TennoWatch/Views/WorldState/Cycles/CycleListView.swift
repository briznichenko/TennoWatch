//
//  CycleListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import SwiftUI

struct CycleListView: View {
    let cycles: [WorldCycleDisplay]

    var body: some View {
        ThemedList {
            ForEach(cycles) { cycle in
                CycleRowView(cycle: cycle)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.cyclesHeader)
        .inlineNavigationTitle()
    }
}
