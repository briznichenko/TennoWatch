//
//  ArchimedeaListView.swift
//  TennoWatch
//

import SwiftUI

struct ArchimedeaListView: View {
    let archimedeas: [Archimedea]

    var body: some View {
        List {
            ForEach(Array(archimedeas.enumerated()), id: \.offset) { _, archimedea in
                Section {
                    ForEach(Array(archimedea.missions.enumerated()), id: \.offset) { _, mission in
                        ArchimedeaMissionRowView(mission: mission)
                    }
                } header: {
                    SectionHeaderLabel(archimedea.type)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.archimedeaHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
