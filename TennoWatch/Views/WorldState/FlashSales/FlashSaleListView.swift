//
//  FlashSaleListView.swift
//  TennoWatch
//

import SwiftUI

struct FlashSaleListView: View {
    let flashSales: [FlashSale]

    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(Array(flashSales.enumerated().filter { $0.element.item.matchesSearch(searchText) }), id: \.offset) { _, flashSale in
                FlashSaleRowView(flashSale: flashSale)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchItems)
        .navigationTitle(Strings.WorldState.flashSalesHeader)
        .inlineNavigationTitle()
    }
}
