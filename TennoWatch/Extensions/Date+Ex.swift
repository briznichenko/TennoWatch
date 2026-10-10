//
//  Date+Ex.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Foundation

extension Date {
    var timeLeftDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.maximumUnitCount = Formatting.maximumCountdownUnits
        return formatter.string(from: Date.now, to: self) ?? ""
    }
}

private struct Formatting {
    static let maximumCountdownUnits = 2
}
