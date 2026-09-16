//
//  ProgressBar.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct ProgressBar: View {
    // MARK: - Object Properties
    let value: Double

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.divider)
                Capsule()
                    .fill(Color.accent)
                    .frame(width: geometry.size.width * value.clamped(to: 0...1))
            }
        }
        .frame(height: 4)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    ProgressBar(value: 0.58)
        .padding()
}
