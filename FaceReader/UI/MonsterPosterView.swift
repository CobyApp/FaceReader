//
//  MonsterPosterView.swift
//  FaceReader
//

import FaceReaderLocalization
import SwiftUI

/// Poster layout used for share / upload (matches legacy scroll content).
struct MonsterPosterView: View {
    let faceImage: UIImage?
    let nicknameLine: String
    let grade: Int
    let totalScore: Int

    private let contentWidth: CGFloat
    private let imageHeight: CGFloat

    init(faceImage: UIImage?, nicknameLine: String, grade: Int, totalScore: Int, screenWidth: CGFloat = UIScreen.main.bounds.width) {
        self.faceImage = faceImage
        self.nicknameLine = nicknameLine
        self.grade = grade
        self.totalScore = totalScore
        contentWidth = screenWidth
        imageHeight = (screenWidth - 40) * 0.8
    }

    var body: some View {
        let imageWidth = contentWidth - 40
        ZStack {
            Image("background")
                .resizable(resizingMode: .tile)
            VStack(spacing: 0) {
                Text(L10n.posterWanted)
                    .font(.app(100))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.horizontal, 10)

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
                        .stroke(Color.appBrown, lineWidth: 5)
                )
                .padding(.horizontal, 20)

                Text(L10n.posterDeadOrAlive)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(nicknameLine)
                    .font(.app(60))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(L10n.gradeLine(for: grade))
                    .font(.app(25))
                    .foregroundStyle(Color.appBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer(minLength: 0)

                Text(L10n.formattedScore(totalScore))
                    .font(.app(50))
                    .foregroundStyle(Color.appBrown)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }
            .frame(width: contentWidth, height: contentWidth * 1.8, alignment: .top)
        }
        .frame(width: contentWidth, height: contentWidth * 1.8)
    }
}

enum PosterImageRenderer {
    @MainActor
    static func render(
        faceImage: UIImage?,
        nicknameLine: String,
        grade: Int,
        totalScore: Int
    ) -> UIImage? {
        let view = MonsterPosterView(faceImage: faceImage, nicknameLine: nicknameLine, grade: grade, totalScore: totalScore)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
