//
//  CRTFrame.swift
//  FaceReader
//

import FaceReaderLocalization
import SwiftUI

/// 카메라 프리뷰 위 4 코너 갈고리 가이드 + 좌상단 REC 깜빡임.
/// VHSOverlay와 달리 프리뷰 위에 직접 올라가지만, 가벼운 도형만 사용해 FPS 영향 최소화.
public struct CRTFrame: View {
    @ObservedObject private var prefs = VHSEffectsPreferences.shared
    @State private var recBlink: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            corners
            recBadge
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                recBlink = true
            }
        }
    }

    private var inkColor: Color { Color(white: 0.96) }

    @ViewBuilder private var corners: some View {
        GeometryReader { geo in
            let inset: CGFloat = 24 * PhoneLayout.metricScale
            let armLength: CGFloat = 28 * PhoneLayout.metricScale
            let lineWidth: CGFloat = 3
            ZStack {
                CornerHook(corner: .topLeading, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: inset + armLength / 2, y: inset + armLength / 2)
                CornerHook(corner: .topTrailing, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: geo.size.width - inset - armLength / 2, y: inset + armLength / 2)
                CornerHook(corner: .bottomLeading, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: inset + armLength / 2, y: geo.size.height - inset - armLength / 2)
                CornerHook(corner: .bottomTrailing, armLength: armLength)
                    .stroke(inkColor, lineWidth: lineWidth)
                    .position(x: geo.size.width - inset - armLength / 2, y: geo.size.height - inset - armLength / 2)
            }
        }
    }

    @ViewBuilder private var recBadge: some View {
        VStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.vhsRed)
                    .frame(width: 12, height: 12)
                    .opacity(prefs.reducedEffects ? 1.0 : (recBlink ? 1.0 : 0.25))
                Text(L10n.vhsRec)
                    .font(.app(16))
                    .fontWeight(.black)
                    .foregroundStyle(Color(white: 0.96))
                Spacer()
            }
            .padding(.horizontal, 36 * PhoneLayout.metricScale)
            .padding(.top, 30 * PhoneLayout.metricScale)
            Spacer()
        }
    }
}

private struct CornerHook: Shape {
    enum Corner { case topLeading, topTrailing, bottomLeading, bottomTrailing }
    let corner: Corner
    let armLength: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c: CGPoint
        let h1: CGPoint
        let h2: CGPoint
        switch corner {
        case .topLeading:
            c = CGPoint(x: rect.minX, y: rect.minY)
            h1 = CGPoint(x: rect.minX + armLength, y: rect.minY)
            h2 = CGPoint(x: rect.minX, y: rect.minY + armLength)
        case .topTrailing:
            c = CGPoint(x: rect.maxX, y: rect.minY)
            h1 = CGPoint(x: rect.maxX - armLength, y: rect.minY)
            h2 = CGPoint(x: rect.maxX, y: rect.minY + armLength)
        case .bottomLeading:
            c = CGPoint(x: rect.minX, y: rect.maxY)
            h1 = CGPoint(x: rect.minX + armLength, y: rect.maxY)
            h2 = CGPoint(x: rect.minX, y: rect.maxY - armLength)
        case .bottomTrailing:
            c = CGPoint(x: rect.maxX, y: rect.maxY)
            h1 = CGPoint(x: rect.maxX - armLength, y: rect.maxY)
            h2 = CGPoint(x: rect.maxX, y: rect.maxY - armLength)
        }
        p.move(to: h1)
        p.addLine(to: c)
        p.addLine(to: h2)
        return p
    }
}

#Preview("CRT") {
    ZStack {
        Color.black.ignoresSafeArea()
        CRTFrame()
    }
}
