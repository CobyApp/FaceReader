//
//  FaceResultView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import FaceReaderUI
import SwiftUI
import UIKit

public struct FaceResultView: View {
    @Bindable var store: StoreOf<FaceResultFeature>

    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    @State private var revealActive: Bool = false

    public init(store: StoreOf<FaceResultFeature>) {
        self.store = store
    }

    private var nicknameDisplay: String {
        let trimmed = (store.report?.codename ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.anonymousMonster : trimmed
    }

    private var loadedDescription: String? {
        let trimmed = (store.report?.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var gradeStamp: PosterGradeStamp {
        let grade = store.box.session.grade
        let tone: KitschStamp.Tone = {
            switch grade {
            case 0: return .cyan
            case 1: return .magenta
            case 2: return .red
            case 3: return .magenta
            default: return .red
            }
        }()
        return PosterGradeStamp(text: L10n.gradeName(for: grade), tone: tone)
    }

    public var body: some View {
        VStack(spacing: 0) {
            customTopBar

            GeometryReader { proxy in
                // 디스플레이만 화면 너비에 맞춰 스케일. 캡처 출력은 여전히 1080×1920 고정.
                let canvasW = MonsterPosterView.canvasWidth
                let canvasH = MonsterPosterView.canvasHeight
                let scale = max(0.01, proxy.size.width / canvasW)
                let displayH = canvasH * scale

                ScrollView(.vertical, showsIndicators: false) {
                    MonsterPosterView(
                        faceImage: posterUIImage,
                        nicknameLine: nicknameDisplay,
                        posterWantedText: L10n.posterWanted,
                        formattedScoreText: L10n.formattedScore(store.box.session.totalScore),
                        descriptionText: loadedDescription,
                        gradeStamp: gradeStamp
                    )
                    .frame(width: canvasW, height: canvasH)
                    .scaleEffect(scale, anchor: .topLeading)
                    // 스케일된 시각 크기를 외곽 frame 으로 잡아 ScrollView 내용 크기 고정 → 가로 드래그 차단.
                    .frame(width: proxy.size.width, height: displayH, alignment: .topLeading)
                    .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            store.send(.onAppear)
            triggerReveal()
        }
        .id(store.posterImageData)
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityView(activityItems: [shareImage])
            }
        }
    }

    @ViewBuilder
    private var customTopBar: some View {
        ZStack {
            Text(L10n.resultScreenTitle)
                .font(.app(16))
                .fontWeight(.semibold)
                .foregroundStyle(Color.appText)
                .frame(maxWidth: .infinity)

            HStack {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.appText)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        store.send(.dismissTapped)
                    }
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(L10n.btnCancel)
                    .padding(.leading, 6)

                Spacer()

                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.appText)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        prepareShare()
                    }
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(L10n.actionShare)
                    .padding(.trailing, 6)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(Color.appBackground)
    }

    private var revealIntensity: Double {
        0.15 + Double(store.box.session.grade) * 0.1
    }

    private func triggerReveal() {
        revealActive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            revealActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                revealActive = false
            }
        }
    }

    private var posterUIImage: UIImage? {
        if let data = store.posterImageData, let img = UIImage(data: data) {
            return img
        }
        return store.box.session.cartoonImage
    }

    private func prepareShare() {
        let totalScore = store.box.session.totalScore
        let img = PosterImageRenderer.render(
            faceImage: posterUIImage,
            nicknameLine: nicknameDisplay,
            posterWantedText: L10n.posterWanted,
            formattedScoreText: L10n.formattedScore(totalScore),
            descriptionText: loadedDescription,
            gradeStamp: gradeStamp
        )
        shareImage = img
        showShareSheet = img != nil
    }
}
