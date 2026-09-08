//
//  MasteryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryView: View {
    @State private var viewModel: MasteryViewModel
    
    init(viewModel: MasteryViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List(viewModel.catalogs) { catalog in
                    NavigationLink(destination: MasteryItemListView(catalogContainer: catalog)) {
                        MasteryCategoryView(catalogContainer: catalog)
                    }.listRowSeparatorTint(.accent)
                }.listStyle(.plain)
                    .listRowSeparatorTint(.accent, edges: .all)
                Spacer()
            }
            .navigationTitle("Mastery")
            .task {
                await viewModel.fetchAll()
            }.refreshable {
                await viewModel.fetchAll()
            }
        }
    }
}


