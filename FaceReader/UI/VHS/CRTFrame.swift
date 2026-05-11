//
//  CRTFrame.swift
//  FaceReader
//

import SwiftUI

/// 직사각형의 4 모서리에 갈고리 가이드 마크.
public struct CornerHook: Shape {
    public enum Corner { case topLeading, topTrailing, bottomLeading, bottomTrailing }
    public let corner: Corner
    public let armLength: CGFloat

    public init(corner: Corner, armLength: CGFloat) {
        self.corner = corner
        self.armLength = armLength
    }

    public func path(in rect: CGRect) -> Path {
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

/// 화면 일부만 카메라가 보이도록 외곽을 어둡게 마스킹하고, 그 viewport 사각형에 4 코너 가이드.
public struct CaptureViewportFrame: View {
    let viewport: CGRect
    let canvasSize: CGSize
    let dimOpacity: Double

    public init(viewport: CGRect, canvasSize: CGSize, dimOpacity: Double = 0.78) {
        self.viewport = viewport
        self.canvasSize = canvasSize
        self.dimOpacity = dimOpacity
    }

    public var body: some View {
        ZStack {
            // 외곽 어둡게 (even-odd fill로 viewport 부분만 뚫음)
            Path { path in
                path.addRect(CGRect(origin: .zero, size: canvasSize))
                path.addRect(viewport)
            }
            .fill(Color.black.opacity(dimOpacity), style: FillStyle(eoFill: true))

            // 4 코너 갈고리
            let armLength: CGFloat = 28 * PhoneLayout.metricScale
            let lineWidth: CGFloat = 3
            let ink = Color(white: 0.96)

            CornerHook(corner: .topLeading, armLength: armLength)
                .stroke(ink, lineWidth: lineWidth)
                .frame(width: armLength, height: armLength)
                .position(x: viewport.minX + armLength / 2, y: viewport.minY + armLength / 2)
            CornerHook(corner: .topTrailing, armLength: armLength)
                .stroke(ink, lineWidth: lineWidth)
                .frame(width: armLength, height: armLength)
                .position(x: viewport.maxX - armLength / 2, y: viewport.minY + armLength / 2)
            CornerHook(corner: .bottomLeading, armLength: armLength)
                .stroke(ink, lineWidth: lineWidth)
                .frame(width: armLength, height: armLength)
                .position(x: viewport.minX + armLength / 2, y: viewport.maxY - armLength / 2)
            CornerHook(corner: .bottomTrailing, armLength: armLength)
                .stroke(ink, lineWidth: lineWidth)
                .frame(width: armLength, height: armLength)
                .position(x: viewport.maxX - armLength / 2, y: viewport.maxY - armLength / 2)
        }
        .allowsHitTesting(false)
    }
}
