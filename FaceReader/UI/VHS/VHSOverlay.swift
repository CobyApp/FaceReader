//
//  VHSOverlay.swift
//  FaceReader
//

import SwiftUI
import UIKit

/// Ambient 텍스처. 스캔라인 + 비네팅 + 절차적 그레인 노이즈.
/// 카메라 프리뷰 위에는 적용 금지 (FPS 영향). UI 레이어에만 사용.
public struct VHSOverlay: ViewModifier {
    @ObservedObject private var prefs = VHSEffectsPreferences.shared

    public init() {}

    public func body(content: Content) -> some View {
        content
            .overlay(scanlines.allowsHitTesting(false))
            .overlay(vignette.allowsHitTesting(false))
            .overlay(grain.allowsHitTesting(false))
    }

    private var intensity: Double { prefs.reducedEffects ? 0.4 : 1.0 }

    @ViewBuilder private var scanlines: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let stripeHeight: CGFloat = 3
                let alpha = 0.06 * intensity
                var y: CGFloat = 0
                while y < size.height {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: stripeHeight / 2)
                    ctx.fill(Path(rect), with: .color(Color.black.opacity(alpha)))
                    y += stripeHeight
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .blendMode(.multiply)
    }

    @ViewBuilder private var vignette: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.5 * intensity)],
                center: .center,
                startRadius: min(geo.size.width, geo.size.height) * 0.3,
                endRadius: max(geo.size.width, geo.size.height) * 0.75
            )
        }
    }

    @ViewBuilder private var grain: some View {
        Image(uiImage: Self.grainImage)
            .resizable(resizingMode: .tile)
            .opacity(0.08 * intensity)
            .blendMode(.overlay)
    }

    /// 그레인은 모듈 로드 시 한 번만 생성하고 캐시.
    private static let grainImage: UIImage = {
        let side: CGFloat = 128
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            var rng = SystemRandomNumberGenerator()
            for _ in 0..<3200 {
                let x = CGFloat.random(in: 0..<side, using: &rng)
                let y = CGFloat.random(in: 0..<side, using: &rng)
                let alpha = CGFloat.random(in: 0.05...0.4, using: &rng)
                cg.setFillColor(UIColor(white: 1, alpha: alpha).cgColor)
                cg.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }()
}

public extension View {
    /// Ambient VHS 텍스처 적용. 카메라 프리뷰 위에는 쓰지 말 것.
    func vhsOverlay() -> some View {
        modifier(VHSOverlay())
    }
}

#Preview("VHSOverlay") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 24) {
            Text("괴인 측정기")
                .font(.app(48))
                .foregroundStyle(Color.vhsInk)
            Text("VHS Ambient Test")
                .font(.app(20))
                .foregroundStyle(Color.vhsInk.opacity(0.7))
        }
    }
    .vhsOverlay()
}
