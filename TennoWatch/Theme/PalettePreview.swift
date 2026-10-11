//
//  PalettePreview.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

private struct PaletteSwatch: Identifiable {
    // MARK: - Object Properties
    let name: String
    let color: Color
    let background: Color

    // MARK: - Computed Properties
    var id: String { name }

    // MARK: - Helper Functions
    private static func relativeLuminance(_ color: Color) -> Double {
        let resolved = color.resolve(in: .init())
        func channel(_ value: Float) -> Double {
            let normalized = Double(value)
            return normalized <= Contrast.linearThreshold ? normalized / Contrast.linearDivisor : pow((normalized + Contrast.gammaOffset) / Contrast.gammaDivisor, Contrast.gammaExponent)
        }
        return Contrast.redWeight * channel(resolved.red) + Contrast.greenWeight * channel(resolved.green) + Contrast.blueWeight * channel(resolved.blue)
    }

    // MARK: - Computed Properties
    var contrastRatio: Double {
        let l1 = Self.relativeLuminance(color)
        let l2 = Self.relativeLuminance(background)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + Contrast.luminanceOffset) / (darker + Contrast.luminanceOffset)
    }

    var hex: String {
        let resolved = color.resolve(in: .init())
        return String(
            format: "#%02X%02X%02X",
            Int((resolved.red * Contrast.maximumColorChannel).rounded()),
            Int((resolved.green * Contrast.maximumColorChannel).rounded()),
            Int((resolved.blue * Contrast.maximumColorChannel).rounded())
        )
    }
}

struct PaletteView: View {
    // MARK: - Computed Properties
    private var swatches: [PaletteSwatch] {
        [
            .init(name: "labelPrimary", color: .labelPrimary, background: .bg),
            .init(name: "labelSecondary", color: .labelSecondary, background: .bg),
            .init(name: "accent", color: .accent, background: .bg),
            .init(name: "accentText", color: .accentText, background: .bg),
            .init(name: "divider", color: .divider, background: .bg)
        ]
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.swatchSpacing) {
                ForEach(swatches) { swatch in
                    HStack(spacing: Layout.swatchSpacing) {
                        RoundedRectangle(cornerRadius: Layout.swatchCornerRadius)
                            .fill(swatch.color)
                            .frame(width: Layout.swatchSize, height: Layout.swatchSize)
                            .overlay(RoundedRectangle(cornerRadius: Layout.swatchCornerRadius).strokeBorder(Color.divider))
                        VStack(alignment: .leading, spacing: Layout.labelSpacing) {
                            Text(swatch.name)
                                .foregroundStyle(Color.labelPrimary)
                            Text("\(swatch.hex) · \(String(format: "%.1f", swatch.contrastRatio)):1 on bg")
                                .font(.caption)
                                .foregroundStyle(Color.labelSecondary)
                        }
                    }
                }

                Surface {
                    VStack(alignment: .leading, spacing: Layout.surfaceSpacing) {
                        Text("surface")
                        Text("Card / row container background")
                            .font(.caption)
                            .foregroundStyle(Color.labelSecondary)
                    }
                    .padding(Layout.surfacePadding)
                }
            }
            .padding()
        }
        .screenBackground()
    }
}

private struct Contrast {
    static let linearThreshold = 0.03928
    static let linearDivisor = 12.92
    static let gammaOffset = 0.055
    static let gammaDivisor = 1.055
    static let gammaExponent = 2.4
    static let redWeight = 0.2126
    static let greenWeight = 0.7152
    static let blueWeight = 0.0722
    static let luminanceOffset = 0.05
    static let maximumColorChannel: Float = 255
}

private struct Layout {
    static let swatchSpacing: CGFloat = 12
    static let swatchCornerRadius: CGFloat = 8
    static let swatchSize: CGFloat = 44
    static let labelSpacing: CGFloat = 2
    static let surfaceSpacing: CGFloat = 4
    static let surfacePadding: CGFloat = 4
}

#Preview("Light") {
    PaletteView()
}

#Preview("Dark") {
    PaletteView()
        .preferredColorScheme(.dark)
}
