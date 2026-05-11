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
    @ObservedObject private var prefs = VHSEffectsPreferences.shared

    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    @State private var revealActive: Bool = false

    public init(store: StoreOf<FaceResultFeature>) {
        self.store = store
    }

    private var nicknameDisplay: String {
        let trimmed = prefs.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.anonymousMonster : trimmed
    }

    public var body: some View {
        VStack(spacing: 0) {
            customTopBar

            ScrollView {
                MonsterPosterView(
                    faceImage: posterUIImage,
                    nicknameLine: nicknameDisplay,
                    posterWantedText: L10n.posterWanted,
                    posterDeadOrAliveText: L10n.posterDeadOrAlive,
                    gradeLineText: L10n.gradeLine(for: store.box.session.grade),
                    formattedScoreText: L10n.formattedScore(store.box.session.totalScore),
                    descriptionText: loadedDescription,
                    gradeStamp: gradeStamp
                )
                .frame(maxWidth: .infinity)
                .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            store.send(.onAppear)
            triggerReveal()
            requestDescriptionIfNeeded()
        }
        .onChange(of: prefs.nickname) { _, _ in
            requestDescriptionIfNeeded(force: true)
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

    /// 포스터 내부에 표시할 텍스트. loaded 상태일 때만 값 반환.
    private var loadedDescription: String? {
        if case let .loaded(text) = store.descriptionStatus { return text }
        return nil
    }

    /// 등급별 스탬프 (이름 + 톤). 위협도가 올라갈수록 시안→마젠타→레드.
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

    private func requestDescriptionIfNeeded(force: Bool = false) {
        switch store.descriptionStatus {
        case .loading:
            return
        case .loaded:
            guard force else { return }
        case .idle, .failed:
            break
        }
        store.send(.requestDescription(nickname: nicknameDisplay))
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
        let grade = store.box.session.grade
        let totalScore = store.box.session.totalScore
        let img = PosterImageRenderer.render(
            faceImage: posterUIImage,
            nicknameLine: nicknameDisplay,
            posterWantedText: L10n.posterWanted,
            posterDeadOrAliveText: L10n.posterDeadOrAlive,
            gradeLineText: L10n.gradeLine(for: grade),
            formattedScoreText: L10n.formattedScore(totalScore),
            descriptionText: loadedDescription,
            gradeStamp: gradeStamp
        )
        shareImage = img
        showShareSheet = img != nil
    }
}
