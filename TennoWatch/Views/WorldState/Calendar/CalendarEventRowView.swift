//
//  CalendarEventRowView.swift
//  TennoWatch
//

import SwiftUI

struct CalendarEventRowView: View {
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.type)
                .font(.subheadline)
                .foregroundStyle(Color.labelPrimary)
            if let challenge = event.challenge {
                Text(challenge.title)
                    .font(.caption)
                Text(challenge.description)
                    .font(.caption2)
                    .foregroundStyle(Color.labelSecondary)
            }
            if let reward = event.reward {
                Text(reward)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            if let upgrade = event.upgrade {
                Text(upgrade.title)
                    .font(.caption)
                Text(upgrade.description)
                    .font(.caption2)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        CalendarEventRowView(
            event: .init(
                type: "Big Prize!",
                challenge: nil,
                reward: "Orokin Reactor Blueprint",
                uniqueName: "reward",
                upgrade: nil
            )
        )
    }
}
