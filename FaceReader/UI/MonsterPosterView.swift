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

/// Poster layout used for share / upload (matches legacy scroll content).
/// Localized strings are passed in so `FaceReaderUI` does not depend on `FaceReaderLocalization`.
public struct MonsterPosterView: View {
    let faceImage: UIImage?
    let nicknameLine: String
    let posterWantedText: String
    let formattedScoreText: String
    let descriptionText: String?
    let gradeStamp: PosterGradeStamp?
    let showVHSAccents: Bool

    private let contentWidth: CGFloat

    public init(
        faceImage: UIImage?,
        nicknameLine: String,
        posterWantedText: String,
        formattedScoreText: String,
        descriptionText: String? = nil,
        gradeStamp: PosterGradeStamp? = nil,
        screenWidth: CGFloat = PhoneLayout.width,
        showVHSAccents: Bool = false
    ) {
        self.faceImage = faceImage
        self.nicknameLine = nicknameLine
        self.posterWantedText = posterWantedText
        self.formattedScoreText = formattedScoreText
        self.descriptionText = descriptionText
        self.gradeStamp = gradeStamp
        self.contentWidth = screenWidth
        self.showVHSAccents = showVHSAccents
    }

    public var body: some View {
        let pad: CGFloat = 20 * PhoneLayout.metricScale
        let imageWidth = contentWidth - pad * 2
        let imageHeight = imageWidth * 0.82
        let border: CGFloat = max(4, 5 * PhoneLayout.metricScale)
        ZStack {
            Image("background")
                .resizable(resizingMode: .tile)
            VStack(spacing: 0) {
                Text(posterWantedText)
                    .font(.app(100))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.35)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12 * PhoneLayout.metricScale)
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
                        KitschStamp(gradeStamp.text, tone: gradeStamp.tone, rotation: -12)
                            .padding(.trailing, -10)
                            .padding(.bottom, -8)
                    }
                }
                .padding(.horizontal, pad)

                Text(nicknameLine)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10 * PhoneLayout.metricScale)
                    .padding(.horizontal, pad)

                if let descriptionText, !descriptionText.isEmpty {
                    Text(descriptionText)
                        .font(.app(20))
                        .foregroundStyle(Color.appBrown.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, pad)
                        .padding(.top, 10 * PhoneLayout.metricScale)
                }

                Spacer(minLength: 0)

                Text(formattedScoreText)
                    .font(.app(50))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .padding(.horizontal, pad)
                    .padding(.bottom, 12 * PhoneLayout.metricScale)
            }
            .frame(width: contentWidth, height: contentWidth * 1.8, alignment: .top)

            if showVHSAccents {
                vhsAccents(pad: pad)
            }
        }
        .frame(width: contentWidth, height: contentWidth * 1.8)
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
        .frame(width: contentWidth, height: contentWidth * 1.8)
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
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
