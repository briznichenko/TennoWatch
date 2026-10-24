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

    @AppStorage(LiquidGlassPreference.storageKey) private var isLiquidGlassEnabled = true
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let usesGlass = isLiquidGlassEnabled && !reduceTransparency
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(usesGlass ? Color.clear : fallbackColor)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.labelSecondary.opacity(usesGlass ? 0 : 0.35), lineWidth: 1)
            }
            .glassEffect(usesGlass ? .regular.tint(tint) : .identity, in: .rect(cornerRadius: cornerRadius))
    }
}

struct AppGlassButtonStyle: PrimitiveButtonStyle {
    var isProminent = false

    @AppStorage(LiquidGlassPreference.storageKey) private var isLiquidGlassEnabled = true
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        if isLiquidGlassEnabled {
            if isProminent {
                GlassProminentButtonStyle().makeBody(configuration: configuration)
            } else {
                GlassButtonStyle().makeBody(configuration: configuration)
            }
        } else {
            Button(role: configuration.role, action: configuration.trigger) {
                configuration.label
                    .foregroundStyle(isProminent ? Color.bg : Color.labelPrimary)
                    .padding(.horizontal, controlSize == .small ? 10 : 12)
                    .padding(.vertical, controlSize == .small ? 5 : 8)
                    .background(isProminent ? Color.dashboardHeroAccent : Color.surface, in: .capsule)
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.labelSecondary.opacity(0.5), lineWidth: 1)
                    }
                    .contentShape(.capsule)
            }
            .buttonStyle(.plain)
            .opacity(isEnabled ? 1 : 0.5)
        }
    }
}
