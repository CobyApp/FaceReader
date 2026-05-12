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
///
/// 캔버스: 360 × 640 (9:16). PosterImageRenderer 가 scale 3 으로 렌더 → 출력 1080 × 1920 px
/// (Instagram story / TikTok 표준 사이즈).
public struct MonsterPosterView: View {
    public static let canvasWidth: CGFloat = 360
    public static let canvasHeight: CGFloat = 640

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
                    .font(.posterDisplay(88))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
                    .padding(.horizontal, 16)

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

                // 코드네임 — 1줄 고정. 긴 영문 코드네임은 minScale 로 자동 축소.
                Text(nicknameLine)
                    .font(.posterApp(44))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(height: 56)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                // 설명 — 고정 박스(2~4줄) 안에서 텍스트 길이에 따라 폰트 자동 조정.
                // 다른 요소는 모두 고정 사이즈/위치 유지.
                Group {
                    if let descriptionText, !descriptionText.isEmpty {
                        Text(descriptionText)
                            .font(.posterApp(Self.descriptionFontSize(for: descriptionText)))
                            .foregroundStyle(Color.appBrown.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.5)
                    }
                }
                .frame(height: 104, alignment: .center)
                .padding(.horizontal, 28)
                .padding(.top, 8)

                Spacer(minLength: 0)

                // 현상금 — 타이프라이터 톤 + 외곽선 박스.
                // 내부 padding: 텍스트와 테두리 사이.
                // .padding(.top, 16): 위 설명과 박스 사이 간격.
                // 마지막 .padding(.horizontal, 24): 박스 외부 좌우 여백 (가장자리에서 떨어짐).
                Text(formattedScoreText)
                    .font(.posterBounty(44))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .overlay(
                        Rectangle()
                            .stroke(Color.appBrown, lineWidth: 3)
                    )
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 22)
            }
            .frame(width: Self.canvasWidth, height: Self.canvasHeight, alignment: .top)

            if showVHSAccents {
                vhsAccents(pad: pad)
            }
        }
        .frame(width: Self.canvasWidth, height: Self.canvasHeight)
    }

    /// 설명 텍스트 길이에 따라 폰트 크기 자동 결정.
    /// 라틴 글자(영어) 는 CJK 보다 한 글자 폭이 절반 정도라 같은 문자 수여도 훨씬 적게 차지 →
    /// ASCII 비율로 두 트랙 분리해 영어는 더 큰 폰트로 시작.
    private static func descriptionFontSize(for text: String) -> CGFloat {
        let count = text.count
        guard count > 0 else { return 22 }
        let asciiCount = text.unicodeScalars.reduce(0) { acc, scalar in
            acc + (scalar.value < 128 ? 1 : 0)
        }
        let isMostlyLatin = Double(asciiCount) / Double(count) > 0.5

        if isMostlyLatin {
            switch count {
            case 0 ... 40:    return 26
            case 41 ... 70:   return 22
            case 71 ... 100:  return 20
            case 101 ... 130: return 18
            default:          return 16
            }
        } else {
            switch count {
            case 0 ... 18:  return 26
            case 19 ... 30: return 22
            case 31 ... 45: return 19
            case 46 ... 60: return 17
            case 61 ... 75: return 15
            default:        return 14
            }
        }
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
