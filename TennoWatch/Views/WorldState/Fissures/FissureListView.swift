//
//  FissureListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct FissureListView: View {
    let groups: [FissureTierGroup]

    var body: some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.fissures, id: \.nodeKey) { fissure in
                        FissureRowView(fissure: fissure)
                    }
                } header: {
                    SectionHeaderLabel(group.tier)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.fissuresHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
