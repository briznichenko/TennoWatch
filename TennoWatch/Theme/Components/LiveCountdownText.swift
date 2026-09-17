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
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let duration = max(0, date.timeIntervalSince(context.date))
                Text(
                    Duration.seconds(duration),
                    format: .units(
                        allowed: [.days, .hours, .minutes, .seconds],
                        width: .narrow
                    )
                )
            }
        }
    }
}

#Preview {
    LiveCountdownText(date: .now.addingTimeInterval(3661))
}
