//
//  LotusLoaderView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct LotusLoaderView: View {
    // MARK: - Object Properties
    var size: CGFloat = LoadingIndicatorSize.standard
    var tint: Color = .labelPrimary

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation = Angle.zero
    @State private var pulseIsDim = false

    // MARK: - Body
    var body: some View {
        ZStack {
            LotusMark()
                .stroke(tint, style: StrokeStyle(lineWidth: size * Appearance.markStrokeRatio, lineCap: .round, lineJoin: .round))
                .frame(width: size * Appearance.markSizeRatio, height: size * Appearance.markSizeRatio)
                .opacity(reduceMotion ? (pulseIsDim ? Appearance.dimOpacity : 1) : 1)
            Circle()
                .trim(from: 0, to: Appearance.arcFraction)
                .stroke(tint, style: StrokeStyle(lineWidth: size * Appearance.arcStrokeRatio, lineCap: .round))
                .rotationEffect(rotation)
                .opacity(reduceMotion ? 0 : 1)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text(Strings.Common.loading))
        .onAppear(perform: startAnimating)
    }

    // MARK: - Helper Functions
    private func startAnimating() {
        if reduceMotion {
            withAnimation(.easeInOut(duration: Appearance.pulseDuration).repeatForever(autoreverses: true)) {
                pulseIsDim = true
            }
        } else {
            withAnimation(.linear(duration: Appearance.rotationDuration).repeatForever(autoreverses: false)) {
                rotation = .degrees(Appearance.fullRotation)
            }
        }
    }
}

private struct Appearance {
    static let markStrokeRatio: CGFloat = 0.045
    static let markSizeRatio: CGFloat = 0.68
    static let dimOpacity = 0.4
    static let arcFraction: CGFloat = 0.22
    static let arcStrokeRatio: CGFloat = 0.06
    static let pulseDuration: TimeInterval = 0.9
    static let rotationDuration: TimeInterval = 1.1
    static let fullRotation: Double = 360
}

#Preview {
    VStack(spacing: 32) {
        LotusLoaderView(size: 88)
        LotusLoaderView(size: 44, tint: .accent)
        LotusLoaderView(size: 20)
    }
    .padding()
    .background(Color.bg)
}
