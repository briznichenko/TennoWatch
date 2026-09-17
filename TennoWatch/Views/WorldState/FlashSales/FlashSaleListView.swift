//
//  FlashSaleListView.swift
//  TennoWatch
//

import SwiftUI

struct FlashSaleListView: View {
    let flashSales: [FlashSale]

    var body: some View {
        List {
            ForEach(Array(flashSales.enumerated()), id: \.offset) { _, flashSale in
                FlashSaleRowView(flashSale: flashSale)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.flashSalesHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
