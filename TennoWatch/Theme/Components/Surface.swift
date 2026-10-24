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
            .appGlassSurface(cornerRadius: Layout.cornerRadius)
    }
}

extension View {
    func appGlassSurface(cornerRadius: CGFloat, tint: Color = .clear) -> some View {
        background {
            AppGlassBackground(cornerRadius: cornerRadius, tint: tint)
        }
    }

    func screenBackground() -> some View {
        self.scrollContentBackground(.hidden).background(.bg)
    }
}

private struct Layout {
    static let contentPadding: CGFloat = 12
    static let cornerRadius: CGFloat = 10
}

struct AppGlassBackground: View {
    var cornerRadius: CGFloat
    var tint: Color = .clear
    var fallbackColor: Color = .surface

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if reduceTransparency {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fallbackColor)
        } else {
            Color.clear
                .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
        }
    }
}
