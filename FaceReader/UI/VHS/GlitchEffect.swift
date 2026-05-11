//
//  GlitchEffect.swift
//  FaceReader
//

import SwiftUI

/// 이벤트 기반 글리치. `active`가 false→true 가 되면 한 번 재생.
/// `accessibilityReduceMotion` 또는 사용자 토글이 켜져 있으면 no-op.
public struct GlitchEffect: ViewModifier {
    public enum Kind {
        case rgbSplit   // 캡처/탭: RGB 채널이 좌우로 어긋났다 정렬
        case tracking   // 결과 진입: 수평 슬라이스가 어긋났다 정렬
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var prefs = VHSEffectsPreferences.shared

    let kind: Kind
    let active: Bool
    let intensity: Double
    let duration: Double

    @State private var t: Double = 0

    public init(
        kind: Kind,
        active: Bool,
        intensity: Double = 1.0,
        duration: Double = 0.3
    ) {
        self.kind = kind
        self.active = active
        self.intensity = intensity
        self.duration = duration
    }

    private var disabled: Bool { reduceMotion || prefs.reducedEffects }

    public func body(content: Content) -> some View {
        Group {
            if disabled {
                content
            } else {
                switch kind {
                case .rgbSplit: rgbSplitBody(content)
                case .tracking: trackingBody(content)
                }
            }
        }
        .onChange(of: active) { _, newValue in
            guard newValue, !disabled else { return }
            play()
        }
    }

    private func play() {
        withAnimation(.easeOut(duration: duration / 2)) { t = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            withAnimation(.easeOut(duration: duration / 2)) { t = 0 }
        }
    }

    @ViewBuilder private func rgbSplitBody(_ content: Content) -> some View {
        let offset = CGFloat(10 * intensity * t)
        ZStack {
            content
            content
                .colorMultiply(Color.vhsCyan)
                .offset(x: -offset, y: 0)
                .opacity(0.6 * t)
                .blendMode(.screen)
                .allowsHitTesting(false)
            content
                .colorMultiply(Color.vhsRed)
                .offset(x: offset, y: 0)
                .opacity(0.6 * t)
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder private func trackingBody(_ content: Content) -> some View {
        GeometryReader { geo in
            let bandY = geo.size.height * 0.45
            let bandHeight = geo.size.height * 0.15
            let shift = CGFloat(40 * intensity * t)
            ZStack {
                content
                content
                    .mask {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: bandY)
                            Color.black.frame(height: bandHeight)
                            Color.clear
                        }
                    }
                    .offset(x: shift, y: 0)
                    .opacity(t)
                    .allowsHitTesting(false)
            }
        }
    }
}

public extension View {
    /// RGB split 글리치 (캡처/탭).
    func glitchRGB(active: Bool, intensity: Double = 1.0, duration: Double = 0.3) -> some View {
        modifier(GlitchEffect(kind: .rgbSplit, active: active, intensity: intensity, duration: duration))
    }

    /// 트래킹 에러 글리치 (결과 진입).
    func glitchTracking(active: Bool, intensity: Double = 1.0, duration: Double = 0.6) -> some View {
        modifier(GlitchEffect(kind: .tracking, active: active, intensity: intensity, duration: duration))
    }
}

#Preview("Glitch RGB") {
    @Previewable @State var fire = false
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 24) {
            Text("REC")
                .font(.app(80))
                .foregroundStyle(Color.vhsRed)
                .glitchRGB(active: fire)
            Button("Trigger") { fire.toggle() }
                .foregroundStyle(Color.vhsInk)
        }
    }
}
