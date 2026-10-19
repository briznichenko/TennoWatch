//
//  SortieDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import SwiftUI

struct SortieDetailView: View {
    let title: String
    let sortie: Sortie

    @State private var searchText = ""

    var body: some View {
        ThemedList {
            SortieRowView(sortie: sortie, searchText: searchText)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchNodes)
        .navigationTitle(title)
        .inlineNavigationTitle()
    }
}
