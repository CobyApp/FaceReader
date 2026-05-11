//
//  KitschStamp.swift
//  FaceReader
//

import SwiftUI

/// 비스듬히 기울어진 도장 스탬프. WANTED 포스터 외곽, Help 등급 라벨 등에 사용.
public struct KitschStamp: View {
    public enum Tone {
        case red    // REC / DANGER / TRACKING ERROR
        case ink    // LEVEL 01 등 중성
    }

    let text: String
    let tone: Tone
    let rotation: Double

    public init(_ text: String, tone: Tone = .red, rotation: Double = -8) {
        self.text = text
        self.tone = tone
        self.rotation = rotation
    }

    private var foreground: Color {
        switch tone {
        case .red: return Color.vhsRed
        case .ink: return Color.vhsInk
        }
    }

    public var body: some View {
        Text(text)
            .font(.app(22))
            .fontWeight(.black)
            .foregroundStyle(foreground)
            .padding(.horizontal, 12 * PhoneLayout.metricScale)
            .padding(.vertical, 6 * PhoneLayout.metricScale)
            .overlay(
                Rectangle()
                    .stroke(foreground, lineWidth: 3 * PhoneLayout.metricScale)
            )
            .rotationEffect(.degrees(rotation))
            .opacity(0.92)
            .accessibilityLabel(text)
    }
}

#Preview("Stamps") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 20) {
            KitschStamp("REC", tone: .red, rotation: -6)
            KitschStamp("DANGER", tone: .red, rotation: 4)
            KitschStamp("TRACKING ERROR", tone: .red, rotation: -10)
            KitschStamp("LEVEL 03", tone: .ink, rotation: 6)
        }
    }
}
