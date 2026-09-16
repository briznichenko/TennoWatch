//
//  LiveCountdownText.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct LiveCountdownText: View {
    let date: Date?

    var body: some View {
        if let date {
            Text(date, style: .timer)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
                .monospacedDigit()
        }
    }
}

#Preview {
    LiveCountdownText(date: .now.addingTimeInterval(3661))
}
