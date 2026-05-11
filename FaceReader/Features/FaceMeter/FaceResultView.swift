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

    /// AI 가 생성한 codename, 없으면 익명 폴백.
    private var nicknameDisplay: String {
        if case let .loaded(codename, _) = store.reportStatus, !codename.isEmpty {
            return codename
        }
        return L10n.anonymousMonster
    }

    /// AI 가 생성한 description, loaded 일 때만.
    private var loadedDescription: String? {
        if case let .loaded(_, description) = store.reportStatus, !description.isEmpty {
            return description
        }
        return nil
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
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    let posterWidth = MonsterPosterView.canvasWidth
                    let availableWidth = proxy.size.width
                    let shrinkScale = min(1.0, availableWidth / posterWidth)
                    let scaledWidth = posterWidth * shrinkScale
                    let scaledHeight = MonsterPosterView.canvasHeight * shrinkScale

                    MonsterPosterView(
                        faceImage: posterUIImage,
                        nicknameLine: nicknameDisplay,
                        posterWantedText: L10n.posterWanted,
                        formattedScoreText: L10n.formattedScore(store.box.session.totalScore),
                        descriptionText: loadedDescription,
                        gradeStamp: gradeStamp
                    )
                    .scaleEffect(shrinkScale, anchor: .topLeading)
                    .frame(width: scaledWidth, height: scaledHeight)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            store.send(.onAppear)
            triggerReveal()
            requestReportIfNeeded()
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

    private func requestReportIfNeeded() {
        switch store.reportStatus {
        case .idle, .failed:
            store.send(.requestReport)
        case .loading, .loaded:
            break
        }
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
