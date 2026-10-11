//
//  LiveCountdownText.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct LiveCountdownText: View {
    let date: Date?
    var font: Font = .caption
    var tint: Color = .labelSecondary
    var showsSeconds = true

    private var allowedUnits: Set<Duration.UnitsFormatStyle.Unit> {
        showsSeconds ? [.days, .hours, .minutes, .seconds] : [.days, .hours, .minutes]
    }
    
    var body: some View {
        if let date {
            TimelineView(.periodic(from: .now, by: showsSeconds ? CountdownRefreshInterval.second : CountdownRefreshInterval.minute)) { context in
                let duration = max(0, date.timeIntervalSince(context.date))
                Text(
                    Duration.seconds(duration),
                    format: .units(
                        allowed: allowedUnits,
                        width: .narrow
                    )
                )
                .font(font)
                .foregroundStyle(tint)
                .monospacedDigit()

            }
        }
    }
}

#Preview {
    LiveCountdownText(date: .now.addingTimeInterval(3661))
}
