//
//  TraderInventoryListView.swift
//  TennoWatch
//

import SwiftUI

struct TraderInventoryListView: View {
    let trader: VoidTrader

    @State private var searchText = ""

    var body: some View {
        ThemedList {
            Section {
                VoidTraderRowView(voidTrader: trader)
            }
            Section {
                ForEach(trader.inventory.filter { $0.item.matchesSearch(searchText) || $0.uniqueName.matchesSearch(searchText) }, id: \.uniqueName) { item in
                    TraderInventoryItemRowView(item: item)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.inventoryHeader)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchItems)
        .navigationTitle(trader.character)
        .inlineNavigationTitle()
    }
}
