//
//  AlertListView.swift
//  TennoWatch
//

import SwiftUI

struct AlertListView: View {
    let alerts: [Alert]

    var body: some View {
        List {
            ForEach(Array(alerts.enumerated()), id: \.offset) { _, alert in
                AlertRowView(alert: alert)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.alertsHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
