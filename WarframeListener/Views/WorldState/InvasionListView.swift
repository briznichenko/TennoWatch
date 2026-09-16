//
//  InvasionListView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct InvasionListView: View {
    let groups: [InvasionPlanetGroup]

    var body: some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.invasions) { invasion in
                        InvasionView(invasion: invasion)
                    }
                } header: {
                    SectionHeaderLabel(group.planet)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.invasionsHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
