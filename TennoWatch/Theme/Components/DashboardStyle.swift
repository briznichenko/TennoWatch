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
        RoundedRectangle(cornerRadius: 26)
            .fill(Color.dashboardHero.gradient)
            .overlay(alignment: .topTrailing) {
                LotusMark()
                    .stroke(DashboardPalette.heroAccent.opacity(0.09), lineWidth: 1)
                    .frame(width: 240, height: 180)
                    .rotationEffect(.degrees(-18))
                    .offset(x: 40, y: -20)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(DashboardPalette.heroAccent.opacity(0.24), lineWidth: 1)
            }
            .clipShape(.rect(cornerRadius: 26))
    }
}

struct DashboardCardBackground: View {
    var cornerRadius: CGFloat = 22

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let accent = DashboardPalette.accent(in: colorScheme)
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.surface)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(
                        colors: [accent.opacity(0.06), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(accent.opacity(0.12), lineWidth: 1)
            }
    }
}

struct DashboardHero<Content: View>: View {
    let title: String
    let icon: String
    var showsDisclosure = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label(title, systemImage: icon)
                    .labelStyle(.titleAndIcon)
                    .font(.caption.weight(.semibold))
                    .tracking(1)
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
        .padding(24)
        .background(DashboardHeroBackground())
    }
}

struct DashboardIcon: View {
    let name: String
    var size: CGFloat = 42

    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .title3) private var scale = 1.0

    var body: some View {
        let accent = DashboardPalette.accent(in: colorScheme)
        Image(systemName: name)
            .font(.title3.weight(.medium))
            .foregroundStyle(accent)
            .frame(width: size * scale, height: size * scale)
            .background(accent.opacity(0.1), in: .rect(cornerRadius: 13))
            .accessibilityHidden(true)
    }
}

struct DashboardMetric: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
        HStack(spacing: 8) {
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
