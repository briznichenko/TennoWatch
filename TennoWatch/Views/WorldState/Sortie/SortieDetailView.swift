//
//  SortieDetailView.swift
//  TennoWatch
//

import SwiftUI

struct SortieDetailView: View {
    let title: String
    let sortie: Sortie

    @State private var searchText = ""

    var body: some View {
        List {
            SortieRowView(sortie: sortie, searchText: searchText)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchNodes)
        .navigationTitle(title)
        .inlineNavigationTitle()
    }
}
