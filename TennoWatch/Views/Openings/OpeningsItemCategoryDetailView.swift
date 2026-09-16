//
//  OpeningsItemCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsItemCategoryDetailView: View {
    let categoryTitle: String
    let items: [MasteryItemViewModel]

    var body: some View {
        List {
            ForEach(items) { item in
                MasteryItemView(viewModel: item)
            }
        }
        .listStyle(.plain)
        .navigationTitle(categoryTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
