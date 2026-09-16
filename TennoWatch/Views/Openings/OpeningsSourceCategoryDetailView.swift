//
//  OpeningsSourceCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsSourceCategoryDetailView: View {
    let categoryTitle: String
    let sources: [MasterySourceViewModel]

    var body: some View {
        List {
            ForEach(sources) { source in
                MasterySourceView(viewModel: source)
            }
        }
        .listStyle(.plain)
        .navigationTitle(categoryTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
