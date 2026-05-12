//
//  MonsterPosterView.swift
//  FaceReader
//

import SwiftUI
import UIKit

/// 포스터에 박힐 등급 스탬프. text 는 등급명 (예: '신급'), tone 은 색.
public struct PosterGradeStamp: Equatable, Sendable {
    public let text: String
    public let tone: KitschStamp.Tone
    public init(text: String, tone: KitschStamp.Tone) {
        self.text = text
        self.tone = tone
    }
}

/// 현상금 포스터 — 디바이스 무관 고정 캔버스(canvasWidth × canvasHeight) 로 렌더링.
/// 다른 아이폰에서도 같은 모양/비율로 보이도록 모든 내부 치수와 폰트가 metricScale 영향을 안 받음.
public struct MonsterPosterView: View {
    public static let canvasWidth: CGFloat = 390
    public static let canvasHeight: CGFloat = canvasWidth * 1.8 // 702

    let faceImage: UIImage?
    let nicknameLine: String
    let posterWantedText: String
    let formattedScoreText: String
    let descriptionText: String?
    let gradeStamp: PosterGradeStamp?
    let showVHSAccents: Bool

    public init(
        faceImage: UIImage?,
        nicknameLine: String,
        posterWantedText: String,
        formattedScoreText: String,
        descriptionText: String? = nil,
        gradeStamp: PosterGradeStamp? = nil,
        showVHSAccents: Bool = false
    ) {
        self.faceImage = faceImage
        self.nicknameLine = nicknameLine
        self.posterWantedText = posterWantedText
        self.formattedScoreText = formattedScoreText
        self.descriptionText = descriptionText
        self.gradeStamp = gradeStamp
        self.showVHSAccents = showVHSAccents
    }

    public var body: some View {
        posterBody
            // 시스템의 글자 크기/Bold Text 같은 접근성 설정과 무관하게 항상 동일 사이즈.
            .dynamicTypeSize(.large)
            .environment(\.legibilityWeight, nil)
    }

    @ViewBuilder
    private var posterBody: some View {
        let pad: CGFloat = 20
        let imageWidth = Self.canvasWidth - pad * 2
        let imageHeight = imageWidth * 0.82
        let border: CGFloat = 5
        ZStack {
            Image("background")
                .resizable(resizingMode: .tile)
            VStack(spacing: 0) {
                Text(posterWantedText)
                    .font(.posterDisplay(96))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.35)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
                    .padding(.horizontal, pad * 0.5)

                Group {
                    if let faceImage {
                        Image(uiImage: faceImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: imageWidth, height: imageHeight)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.appBrown, lineWidth: border)
                )
                .overlay(alignment: .bottomTrailing) {
                    if let gradeStamp {
                        posterStamp(text: gradeStamp.text, tone: gradeStamp.tone)
                            .padding(.trailing, -10)
                            .padding(.bottom, -8)
                    }
                }
                .padding(.horizontal, pad)
                .padding(.top, 8)

                Text(nicknameLine)
                    .font(.posterApp(52))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, pad)

                if let descriptionText, !descriptionText.isEmpty {
                    Text(descriptionText)
                        .font(.posterApp(20))
                        .foregroundStyle(Color.appBrown.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, pad)
                        .padding(.top, 8)
                }

                Spacer(minLength: 0)

                // 현상금 — 타이프라이터 톤으로 'official' 느낌. 외곽선으로 강조.
                Text(formattedScoreText)
                    .font(.posterBounty(54))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .overlay(
                        Rectangle()
                            .stroke(Color.appBrown, lineWidth: 3)
                    )
                    .padding(.bottom, 18)
            }
            .frame(width: Self.canvasWidth, height: Self.canvasHeight, alignment: .top)

            if showVHSAccents {
                vhsAccents(pad: pad)
            }
        }
        .frame(width: Self.canvasWidth, height: Self.canvasHeight)
    }

    /// 포스터 안쪽에 사용하는 KitschStamp 의 고정-사이즈 버전.
    @ViewBuilder
    private func posterStamp(text: String, tone: KitschStamp.Tone) -> some View {
        let color = toneColor(tone)
        Text(text)
            .font(.posterApp(20))
            .fontWeight(.black)
            .foregroundStyle(Color(white: 0.97))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .overlay(
                Rectangle()
                    .stroke(Color.black.opacity(0.55), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 1, y: 1)
            .rotationEffect(.degrees(-12))
    }

    private func toneColor(_ tone: KitschStamp.Tone) -> Color {
        switch tone {
        case .red: return Color.vhsRed
        case .cyan: return Color.vhsCyan
        case .magenta: return Color.vhsMagenta
        case .ink: return Color.vhsInk
        }
    }

    @ViewBuilder
    private func vhsAccents(pad: CGFloat) -> some View {
        VStack {
            HStack {
                Spacer()
                KitschStamp("TRACKING ERROR", tone: .red, rotation: -10)
                    .padding(.trailing, pad)
                    .padding(.top, pad * 0.6)
            }
            Spacer()
            HStack {
                KitschStamp("DANGER", tone: .red, rotation: 6)
                    .padding(.leading, pad)
                Spacer()
            }
            .padding(.bottom, pad * 0.4)
        }
        .frame(width: Self.canvasWidth, height: Self.canvasHeight)
    }
}

public enum PosterImageRenderer {
    @MainActor
    public static func render(
        faceImage: UIImage?,
        nicknameLine: String,
        posterWantedText: String,
        formattedScoreText: String,
        descriptionText: String? = nil,
        gradeStamp: PosterGradeStamp? = nil,
        showVHSAccents: Bool = false
    ) -> UIImage? {
        let view = MonsterPosterView(
            faceImage: faceImage,
            nicknameLine: nicknameLine,
            posterWantedText: posterWantedText,
            formattedScoreText: formattedScoreText,
            descriptionText: descriptionText,
            gradeStamp: gradeStamp,
            showVHSAccents: showVHSAccents
        )
        let renderer = ImageRenderer(content: view)
        // 디바이스 무관 고정 출력 (≈ 3x retina). 결과: 1170 × 2106 px.
        renderer.scale = 3.0
        return renderer.uiImage
    }
}
