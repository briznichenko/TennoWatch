//
//  SectionHeader.swift
//  TennoWatch
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
            .font(.title2)
            .tracking(Layout.letterSpacing)
            .foregroundStyle(Color.labelSecondary)
    }
}

private struct Layout {
    static let letterSpacing: CGFloat = 0.44
}

#Preview {
    SectionHeaderLabel("Test")
}
