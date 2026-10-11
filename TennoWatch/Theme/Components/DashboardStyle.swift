//
//  WorldStateGridView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/09/26.
//

import SwiftUI

enum DashboardPalette {
    static let gold = Color(red: 0.89, green: 0.74, blue: 0.43)
    static let heroAccent = Color.dashboardHeroAccent

    static func accent(in scheme: ColorScheme) -> Color {
        scheme == .dark ? gold : .accent
    }
}

struct DashboardHeroBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: HeroStyle.cornerRadius)
            .fill(Color.dashboardHero.gradient)
            .overlay(alignment: .topTrailing) {
                LotusMark()
                    .stroke(DashboardPalette.heroAccent.opacity(HeroStyle.watermarkOpacity), lineWidth: HeroStyle.borderWidth)
                    .frame(width: HeroStyle.watermarkWidth, height: HeroStyle.watermarkHeight)
                    .rotationEffect(.degrees(HeroStyle.watermarkAngle))
                    .offset(x: HeroStyle.watermarkOffsetX, y: HeroStyle.watermarkOffsetY)
            }
            .overlay {
                RoundedRectangle(cornerRadius: HeroStyle.cornerRadius)
                    .strokeBorder(DashboardPalette.heroAccent.opacity(HeroStyle.borderOpacity), lineWidth: HeroStyle.borderWidth)
            }
            .clipShape(.rect(cornerRadius: HeroStyle.cornerRadius))
    }
}

struct DashboardCardBackground: View {
    var cornerRadius: CGFloat = DashboardLayout.cardCornerRadius

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let accent = DashboardPalette.accent(in: colorScheme)
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.surface)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(
                        colors: [accent.opacity(CardStyle.gradientOpacity), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(accent.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            }
    }
}

struct DashboardHero<Content: View>: View {
    let title: String
    let icon: String
    var showsDisclosure = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: HeroStyle.contentSpacing) {
            HStack {
                Label(title, systemImage: icon)
                    .labelStyle(.titleAndIcon)
                    .font(.caption.weight(.semibold))
                    .tracking(DashboardLayout.headingTracking)
                Spacer()
                if showsDisclosure {
                    Image(systemName: "arrow.up.right")
                        .font(.subheadline.weight(.semibold))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(DashboardPalette.heroAccent)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DashboardLayout.contentPadding)
        .background(DashboardHeroBackground())
    }
}

struct DashboardIcon: View {
    let name: String
    var size: CGFloat = IconStyle.size

    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .title3) private var scale = 1.0

    var body: some View {
        let accent = DashboardPalette.accent(in: colorScheme)
        Image(systemName: name)
            .font(.title3.weight(.medium))
            .foregroundStyle(accent)
            .frame(width: size * scale, height: size * scale)
            .background(accent.opacity(IconStyle.backgroundOpacity), in: .rect(cornerRadius: IconStyle.cornerRadius))
            .accessibilityHidden(true)
    }
}

struct DashboardMetric: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: MetricStyle.labelSpacing) {
            Text(value)
                .font(.system(.title, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

struct DashboardSectionHeader: View {
    let title: String
    var icon: String?

    var body: some View {
        HStack(spacing: SectionStyle.iconSpacing) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(Color.accent)
                    .accessibilityHidden(true)
            }
            Text(title)
                .foregroundStyle(Color.labelPrimary)
        }
        .font(.headline)
        .textCase(nil)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct HeroStyle {
    static let cornerRadius: CGFloat = 26
    static let watermarkOpacity = 0.09
    static let borderWidth: CGFloat = 1
    static let watermarkWidth: CGFloat = 240
    static let watermarkHeight: CGFloat = 180
    static let watermarkAngle: Double = -18
    static let watermarkOffsetX: CGFloat = 40
    static let watermarkOffsetY: CGFloat = -20
    static let borderOpacity = 0.24
    static let contentSpacing: CGFloat = 14
}

private struct CardStyle {
    static let gradientOpacity = 0.06
    static let borderOpacity = 0.12
    static let borderWidth: CGFloat = 1
}

private struct IconStyle {
    static let size: CGFloat = 36
    static let backgroundOpacity = 0.1
    static let cornerRadius: CGFloat = 13
}

private struct MetricStyle {
    static let labelSpacing: CGFloat = 4
}

private struct SectionStyle {
    static let iconSpacing: CGFloat = 8
}
