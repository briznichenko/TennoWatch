//
//  NightwaveRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct NightwaveRowView: View {
    let nightwave: Nightwave

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(nightwave.tag)
                .font(.headline)
            ForEach(Array(nightwave.activeChallenges.enumerated()), id: \.offset) { _, challenge in
                HStack {
                    Text(challenge.title)
                    Spacer()
                    Text("+\(Int(challenge.reputation))")
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
        }
    }
}

#Preview {
    List {
        NightwaveRowView(
            nightwave: .init(
                activation: .now,
                expiry: .now.addingTimeInterval(3600),
                id: "nightwave",
                activeChallenges: [
                    .init(
                        activation: .now,
                        expiry: .now.addingTimeInterval(3600),
                        id: "challenge",
                        desc: "Complete a mission",
                        isDaily: true,
                        isElite: false,
                        isPermanent: false,
                        reputation: 1000,
                        title: "Complete a mission"
                    )
                ],
                phase: 1,
                possibleChallenges: [],
                season: 1,
                tag: "Nightwave Season"
            )
        )
    }
}
