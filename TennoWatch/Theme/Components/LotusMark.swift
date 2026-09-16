//
//  LotusMark.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct LotusMark: Shape {
    private enum Curve {
        case cubic(CGPoint, CGPoint, CGPoint)
        case quad(CGPoint, CGPoint)
    }

    private struct Segment {
        let start: CGPoint
        let curves: [Curve]
    }

    private static let aspectRatio: CGFloat = 496.0 / 323.0
    private static let segments: [Segment] = [
        Segment(
            start: CGPoint(x: 0.2198, y: 0.3839),
            curves: [
                .cubic(CGPoint(x: 0.2177, y: 0.2818), CGPoint(x: 0.2298, y: 0.2074), CGPoint(x: 0.2520, y: 0.1424)),
                .quad(CGPoint(x: 0.2641, y: 0.1084), CGPoint(x: 0.2883, y: 0.1238)),
                .cubic(CGPoint(x: 0.3206, y: 0.1455), CGPoint(x: 0.3508, y: 0.1765), CGPoint(x: 0.3851, y: 0.2167))
            ]
        ),
        Segment(
            start: CGPoint(x: 0.3468, y: 0.4706),
            curves: [
                .cubic(CGPoint(x: 0.3065, y: 0.4179), CGPoint(x: 0.2298, y: 0.3839), CGPoint(x: 0.1613, y: 0.3746)),
                .quad(CGPoint(x: 0.1310, y: 0.3715), CGPoint(x: 0.1310, y: 0.4179)),
                .cubic(CGPoint(x: 0.1290, y: 0.7152), CGPoint(x: 0.2661, y: 0.9381), CGPoint(x: 0.5000, y: 0.9845))
            ]
        ),
        Segment(
            start: CGPoint(x: 0.1371, y: 0.6161),
            curves: [
                .cubic(CGPoint(x: 0.1089, y: 0.6161), CGPoint(x: 0.0746, y: 0.6254), CGPoint(x: 0.0302, y: 0.6502)),
                .quad(CGPoint(x: 0.0000, y: 0.6688), CGPoint(x: 0.0121, y: 0.7121)),
                .cubic(CGPoint(x: 0.0726, y: 0.9010), CGPoint(x: 0.2460, y: 1.0000), CGPoint(x: 0.5000, y: 0.9845))
            ]
        ),
        Segment(
            start: CGPoint(x: 0.5000, y: 0.9845),
            curves: [
                .cubic(CGPoint(x: 0.4113, y: 0.8204), CGPoint(x: 0.3488, y: 0.6780), CGPoint(x: 0.3488, y: 0.5046)),
                .cubic(CGPoint(x: 0.3488, y: 0.3065), CGPoint(x: 0.4032, y: 0.1517), CGPoint(x: 0.4819, y: 0.0279)),
                .quad(CGPoint(x: 0.5000, y: 0.0000), CGPoint(x: 0.5181, y: 0.0279))
            ]
        )
    ]

    func path(in rect: CGRect) -> Path {
        let drawRect = rect.fitting(aspectRatio: Self.aspectRatio)
        var path = Path()
        for segment in Self.segments {
            path.addPath(Self.build(segment, in: drawRect, mirrored: false))
            path.addPath(Self.build(segment, in: drawRect, mirrored: true))
        }
        return path
    }

    private static func build(_ segment: Segment, in rect: CGRect, mirrored: Bool) -> Path {
        func point(_ p: CGPoint) -> CGPoint {
            let x = mirrored ? 1 - p.x : p.x
            return CGPoint(x: rect.minX + x * rect.width, y: rect.minY + p.y * rect.height)
        }

        var path = Path()
        path.move(to: point(segment.start))
        for curve in segment.curves {
            switch curve {
            case .cubic(let control1, let control2, let end):
                path.addCurve(to: point(end), control1: point(control1), control2: point(control2))
            case .quad(let control, let end):
                path.addQuadCurve(to: point(end), control: point(control))
            }
        }
        return path
    }
}

private extension CGRect {
    func fitting(aspectRatio: CGFloat) -> CGRect {
        if width / height > aspectRatio {
            let fittedWidth = height * aspectRatio
            return CGRect(x: minX + (width - fittedWidth) / 2, y: minY, width: fittedWidth, height: height)
        } else {
            let fittedHeight = width / aspectRatio
            return CGRect(x: minX, y: minY + (height - fittedHeight) / 2, width: width, height: fittedHeight)
        }
    }
}

#Preview {
    LotusMark()
        .stroke(Color.labelPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        .frame(width: 160, height: 160)
        .padding()
}
