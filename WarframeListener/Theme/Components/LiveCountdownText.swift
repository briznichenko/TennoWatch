//
//  LiveCountdownText.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

/// A "time remaining" label that keeps itself up to date. `Text(_:style:)`
/// re-renders on its own schedule, so no Combine `Timer` publisher or manual
/// refresh loop is needed for a ticking countdown.
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
