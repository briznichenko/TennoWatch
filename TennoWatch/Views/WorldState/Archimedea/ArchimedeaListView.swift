//
//  ArchimedeaListView.swift
//  TennoWatch
//

import SwiftUI

struct ArchimedeaListView: View {
    let archimedeas: [Archimedea]

    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(Array(archimedeas.enumerated()), id: \.offset) { _, archimedea in
                let missions = archimedea.missions.filter {
                    [$0.missionType, $0.faction, archimedea.type].joined(separator: " ").matchesSearch(searchText)
                }
                if !missions.isEmpty {
                    Section {
                        ForEach(Array(missions.enumerated()), id: \.offset) { _, mission in
                            ArchimedeaMissionRowView(mission: mission)
                        }
                    } header: {
                        SectionHeaderLabel(archimedea.type)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.search)
        .navigationTitle(Strings.WorldState.archimedeaHeader)
        .inlineNavigationTitle()
    }
}
