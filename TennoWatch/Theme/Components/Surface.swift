//
//  Surface.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import SwiftUI

struct Surface<Content: View>: View {
    // MARK: - Object Properties
    @ViewBuilder var content: Content

    // MARK: - Body
    var body: some View {
        content
            .padding(Layout.contentPadding)
            .background(.surface, in: .rect(cornerRadius: Layout.cornerRadius))
    }
}

extension View {
    func screenBackground() -> some View {
        self.scrollContentBackground(.hidden).background(.bg)
    }
}

private struct Layout {
    static let contentPadding: CGFloat = 12
    static let cornerRadius: CGFloat = 10
}
