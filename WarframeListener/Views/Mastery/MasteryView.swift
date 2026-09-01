//
//  MasteryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryView: View {
    @State private var viewModel: MasteryViewModel
    
    init(viewModel: MasteryViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List(viewModel.catalogs) { catalog in
                    NavigationLink(destination: makeItemList(for: catalog.items)) {
                        CategoryView(catalog: catalog)
                    }
                }.listStyle(.grouped)
                Spacer()
            }
            .navigationTitle("Mastery")
            .task {
                await viewModel.fetchCatalog()
            }
        }
    }
    
    private func makeItemList(for items: [CatalogItem]) -> some View {
        List(items) { item in
            MasteryItemView(item: .init(item: item))
        }
    }
}

#Preview {
    MasteryView(viewModel: .init())
}
