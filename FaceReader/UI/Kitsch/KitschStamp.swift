//
//  KitschStamp.swift
//  FaceReader
//

import SwiftUI

/// 비스듬히 기울어진 도장 스탬프. WANTED 포스터 외곽, Help 등급 라벨 등에 사용.
public struct KitschStamp: View {
    public enum Tone {
        case red        // 고등급
        case cyan       // 저등급
        case magenta    // 중등급
        case ink        // 중성
    }

    let text: String
    let tone: Tone
    let rotation: Double
    let solid: Bool

    public init(_ text: String, tone: Tone = .red, rotation: Double = -8, solid: Bool = true) {
        self.text = text
        self.tone = tone
        self.rotation = rotation
        self.solid = solid
    }

    private var color: Color {
        switch tone {
        case .red: return Color.vhsRed
        case .cyan: return Color.vhsCyan
        case .magenta: return Color.vhsMagenta
        case .ink: return Color.vhsInk
        }
    }

    public var body: some View {
        Text(text)
            .font(.app(20))
            .fontWeight(.black)
            .foregroundStyle(solid ? Color(white: 0.97) : color)
            .padding(.horizontal, 12 * PhoneLayout.metricScale)
            .padding(.vertical, 6 * PhoneLayout.metricScale)
            .background(solid ? color : Color.clear)
            .overlay(
                Rectangle()
                    .stroke(solid ? Color.black.opacity(0.55) : color, lineWidth: solid ? 2 : 3 * PhoneLayout.metricScale)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 2, x: 1, y: 2)
            .rotationEffect(.degrees(rotation))
            .accessibilityLabel(text)
    }
}

#Preview("Stamps") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 20) {
            KitschStamp("LEVEL 01", tone: .cyan, rotation: -6)
            KitschStamp("LEVEL 02", tone: .magenta, rotation: 4)
            KitschStamp("LEVEL 03", tone: .red, rotation: -10)
            KitschStamp("LEVEL 04", tone: .ink, rotation: 6, solid: false)
        }
    }
}
