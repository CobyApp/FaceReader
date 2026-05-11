//
//  MonsterPosterView.swift
//  FaceReader
//

import SwiftUI
import UIKit

/// Poster layout used for share / upload (matches legacy scroll content).
/// Localized strings are passed in so `FaceReaderUI` does not depend on `FaceReaderLocalization`.
public struct MonsterPosterView: View {
    let faceImage: UIImage?
    let nicknameLine: String
    let posterWantedText: String
    let posterDeadOrAliveText: String
    let gradeLineText: String
    let formattedScoreText: String
    let showVHSAccents: Bool

    private let contentWidth: CGFloat

    public init(
        faceImage: UIImage?,
        nicknameLine: String,
        posterWantedText: String,
        posterDeadOrAliveText: String,
        gradeLineText: String,
        formattedScoreText: String,
        screenWidth: CGFloat = PhoneLayout.width,
        showVHSAccents: Bool = false
    ) {
        self.faceImage = faceImage
        self.nicknameLine = nicknameLine
        self.posterWantedText = posterWantedText
        self.posterDeadOrAliveText = posterDeadOrAliveText
        self.gradeLineText = gradeLineText
        self.formattedScoreText = formattedScoreText
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
                .padding(.horizontal, pad)

                Text(posterDeadOrAliveText)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, pad)

                Text(nicknameLine)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.45)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, pad)

                Text(gradeLineText)
                    .font(.app(25))
                    .foregroundStyle(Color.appBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, pad)

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
        posterDeadOrAliveText: String,
        gradeLineText: String,
        formattedScoreText: String,
        showVHSAccents: Bool = false
    ) -> UIImage? {
        let view = MonsterPosterView(
            faceImage: faceImage,
            nicknameLine: nicknameLine,
            posterWantedText: posterWantedText,
            posterDeadOrAliveText: posterDeadOrAliveText,
            gradeLineText: gradeLineText,
            formattedScoreText: formattedScoreText,
            showVHSAccents: showVHSAccents
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
