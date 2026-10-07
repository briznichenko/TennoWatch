//
//  IntrinsicsView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct IntrinsicsView: View {
    // MARK: - Object Properties
    let groups: [IntrinsicGroup]

    @State private var searchText = ""

    private var filteredGroups: [IntrinsicGroup] {
        groups.compactMap { group in
            let matches = group.intrinsics.filter {
                [$0.name, $0.key, group.name].joined(separator: " ").matchesSearch(searchText)
            }
            return matches.isEmpty ? nil : IntrinsicGroup(name: group.name, intrinsics: matches)
        }
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(filteredGroups) { group in
                Section {
                    ForEach(group.intrinsics) { intrinsic in
                        IntrinsicRowView(intrinsic: intrinsic)
                    }
                } header: {
                    SectionHeaderLabel(group.name)
                }
            }
        }
        .themedList()
        .searchable(text: $searchText, prompt: Strings.Common.search)
        .navigationTitle(Strings.Profile.intrinsicsTitle)
        .inlineNavigationTitle()
    }
}
