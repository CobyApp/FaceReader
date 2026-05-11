//
//  SubtitleBox.swift
//  FaceReader
//

import SwiftUI

/// 옛날 비디오 자막 박스. 검정 띠 배경 + 크림색 글씨 + 얇은 외곽선.
public struct SubtitleBox: View {
    let text: String
    let size: CGFloat

    public init(_ text: String, size: CGFloat = 20) {
        self.text = text
        self.size = size
    }

    public var body: some View {
        Text(text)
            .font(.app(size))
            .foregroundStyle(Color(white: 0.96))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 14 * PhoneLayout.metricScale)
            .padding(.vertical, 8 * PhoneLayout.metricScale)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.82))
            )
            .overlay(
                Rectangle()
                    .stroke(Color(white: 0.96).opacity(0.4), lineWidth: 1)
            )
            .accessibilityLabel(text)
    }
}

#Preview("Subtitles") {
    ZStack {
        Color.vhsBase.ignoresSafeArea()
        VStack(spacing: 16) {
            SubtitleBox("얼굴 비율로 괴인 등급을 측정합니다.", size: 22)
            SubtitleBox("얼굴 사진은 카툰화 이미지로 변경됩니다.", size: 18)
        }
        .padding()
    }
}
