//
//  AlertListView.swift
//  TennoWatch
//

import SwiftUI

struct AlertListView: View {
    let alerts: [Alert]

    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(Array(alerts.enumerated().filter {
                [$0.element.mission.node, $0.element.mission.nodeKey, $0.element.mission.type,
                 $0.element.rewardTypes.joined(separator: " ")].joined(separator: " ").matchesSearch(searchText)
            }), id: \.offset) { _, alert in
                AlertRowView(alert: alert)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: Strings.Common.searchNodes)
        .navigationTitle(Strings.WorldState.alertsHeader)
        .inlineNavigationTitle()
    }
}
