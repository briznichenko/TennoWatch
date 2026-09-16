//
//  NightwaveChallengeRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct NightwaveChallengeRowView: View {
    let challenge: NightwaveChallenge

    var body: some View {
        HStack {
            Text(challenge.title)
            Spacer()
            Text("+\(Int(challenge.reputation))")
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
    }
}

#Preview {
    List {
        NightwaveChallengeRowView(
            challenge: .init(
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
        )
    }
}
