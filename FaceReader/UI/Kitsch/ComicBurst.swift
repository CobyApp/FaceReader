//
//  ComicBurst.swift
//  FaceReader
//

import SwiftUI

/// 폭발형 별 모양 말풍선. 결과 화면 점수/등급 강조용.
public struct ComicBurst: View {
    let text: String
    let points: Int
    let rotation: Double

    public init(_ text: String, points: Int = 10, rotation: Double = -4) {
        self.text = text
        self.points = points
        self.rotation = rotation
    }

    public var body: some View {
        ZStack {
            BurstShape(points: points)
                .fill(Color.vhsBase)
            BurstShape(points: points)
                .stroke(Color.vhsInk, lineWidth: 4 * PhoneLayout.metricScale)
            Text(text)
                .font(.app(28))
                .fontWeight(.black)
                .foregroundStyle(Color.vhsInk)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24 * PhoneLayout.metricScale)
                .padding(.vertical, 16 * PhoneLayout.metricScale)
        }
        .rotationEffect(.degrees(rotation))
        .accessibilityLabel(text)
    }
}

private struct BurstShape: Shape {
    let points: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.72
        var path = Path()
        let total = points * 2
        for i in 0..<total {
            let radius = i.isMultiple(of: 2) ? outerR : innerR
            let angle = (Double(i) / Double(total)) * .pi * 2 - .pi / 2
            let c: Double = cos(angle)
            let s: Double = sin(angle)
            let point = CGPoint(
                x: center.x + radius * c,
                y: center.y + radius * s
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

#Preview("Burst") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        ComicBurst("$1,234,567", points: 12, rotation: -6)
            .frame(width: 260, height: 260)
    }
}
