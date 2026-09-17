//
//  WorldStateCardView.swift
//  TennoWatch
//

import SwiftUI

struct CardView<Summary: View>: View {
    // MARK: - Object Properties
    let icon: String
    let title: String
    @ViewBuilder var summary: Summary

    // MARK: - Body
    var body: some View {
        Surface {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.accent)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)
                summary
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 84, alignment: .topLeading)
        }
        .contentShape(.rect)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        CardView(icon: "envelope.fill", title: "Alerts") {
            Text("3")
        }
        CardView(icon: "person.fill.questionmark", title: "Void trader") {
            LiveCountdownText(date: .now.addingTimeInterval(3600))
        }
    }
    .padding(12)
}
