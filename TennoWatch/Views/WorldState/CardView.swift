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
        VStack(alignment: .leading, spacing: Layout.contentSpacing) {
            HStack {
                DashboardIcon(name: icon)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.labelSecondary.opacity(Layout.disclosureOpacity))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: Layout.summarySpacing) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)
                summary
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.labelSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: Layout.minimumSummaryHeight, alignment: .topLeading)
        }
        .padding(Layout.contentPadding)
        .background(DashboardCardBackground())
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

private struct Layout {
    static let contentSpacing: CGFloat = 10
    static let summarySpacing: CGFloat = 4
    static let disclosureOpacity = 0.7
    static let minimumSummaryHeight: CGFloat = 44
    static let contentPadding: CGFloat = 12
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
