//
//  LotusLoaderView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct LotusLoaderView: View {
    // MARK: - Object Properties
    var size: CGFloat = 64
    var tint: Color = .labelPrimary

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation = Angle.zero
    @State private var pulseIsDim = false

    // MARK: - Body
    var body: some View {
        ZStack {
            LotusMark()
                .stroke(tint, style: StrokeStyle(lineWidth: size * 0.045, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.68, height: size * 0.68)
                .opacity(reduceMotion ? (pulseIsDim ? 0.4 : 1) : 1)
            Circle()
                .trim(from: 0, to: 0.22)
                .stroke(tint, style: StrokeStyle(lineWidth: size * 0.06, lineCap: .round))
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
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulseIsDim = true
            }
        } else {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                rotation = .degrees(360)
            }
        }
    }
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
