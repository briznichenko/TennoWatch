//
//  TraderInventoryListView.swift
//  TennoWatch
//

import SwiftUI

struct TraderInventoryListView: View {
    let trader: VoidTrader

    var body: some View {
        List {
            Section {
                VoidTraderRowView(voidTrader: trader)
            }
            Section {
                ForEach(trader.inventory, id: \.uniqueName) { item in
                    TraderInventoryItemRowView(item: item)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.inventoryHeader)
            }
        }
        .listStyle(.plain)
        .navigationTitle(trader.character)
        .navigationBarTitleDisplayMode(.inline)
    }
}
