//
//  SortieDetailView.swift
//  TennoWatch
//

import SwiftUI

struct SortieDetailView: View {
    let title: String
    let sortie: Sortie

    var body: some View {
        List {
            SortieRowView(sortie: sortie)
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
