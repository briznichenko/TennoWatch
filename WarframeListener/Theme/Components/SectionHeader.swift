//
//  SectionHeader.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct SectionHeaderLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11))
            .tracking(0.44)
            .foregroundStyle(Color.labelSecondary)
    }
}

extension View {
    func sectionHeader(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeaderLabel(title)
            self
        }
    }
}
