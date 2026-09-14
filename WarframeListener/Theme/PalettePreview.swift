//
//  PalettePreview.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

private struct PaletteSwatch: Identifiable {
    let name: String
    let color: Color
    let background: Color

    var id: String { name }

    private static func relativeLuminance(_ color: Color) -> Double {
        let resolved = color.resolve(in: .init())
        func channel(_ value: Float) -> Double {
            let normalized = Double(value)
            return normalized <= 0.03928 ? normalized / 12.92 : pow((normalized + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(resolved.red) + 0.7152 * channel(resolved.green) + 0.0722 * channel(resolved.blue)
    }

    var contrastRatio: Double {
        let l1 = Self.relativeLuminance(color)
        let l2 = Self.relativeLuminance(background)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    var hex: String {
        let resolved = color.resolve(in: .init())
        return String(
            format: "#%02X%02X%02X",
            Int((resolved.red * 255).rounded()),
            Int((resolved.green * 255).rounded()),
            Int((resolved.blue * 255).rounded())
        )
    }
}

struct PaletteView: View {
    private var swatches: [PaletteSwatch] {
        [
            .init(name: "label", color: .label, background: .bg),
            .init(name: "labelSecondary", color: .labelSecondary, background: .bg),
            .init(name: "accent", color: .accent, background: .bg),
            .init(name: "accentText", color: .accentText, background: .bg),
            .init(name: "separator", color: .separator, background: .bg)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(swatches) { swatch in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(swatch.color)
                            .frame(width: 44, height: 44)
                            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.separator))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(swatch.name)
                                .foregroundStyle(Color.label)
                            Text("\(swatch.hex) · \(String(format: "%.1f", swatch.contrastRatio)):1 on bg")
                                .font(.caption)
                                .foregroundStyle(Color.labelSecondary)
                        }
                    }
                }

                Surface {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("surface")
                        Text("Card / row container background")
                            .font(.caption)
                            .foregroundStyle(Color.labelSecondary)
                    }
                    .padding(4)
                }
            }
            .padding()
        }
        .screenBackground()
    }
}

#Preview("Light") {
    PaletteView()
}

#Preview("Dark") {
    PaletteView()
        .preferredColorScheme(.dark)
}
