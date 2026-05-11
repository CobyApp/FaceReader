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
                VStack(spacing: 16 * PhoneLayout.metricScale) {
                    MonsterPosterView(
                        faceImage: posterUIImage,
                        nicknameLine: nicknameDisplay,
                        posterWantedText: L10n.posterWanted,
                        posterDeadOrAliveText: L10n.posterDeadOrAlive,
                        gradeLineText: L10n.gradeLine(for: store.box.session.grade),
                        formattedScoreText: L10n.formattedScore(store.box.session.totalScore)
                    )
                    .frame(maxWidth: .infinity)
                    .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)

                    if shouldShowDescription {
                        descriptionCard
                            .padding(.horizontal, 18 * PhoneLayout.metricScale)
                            .padding(.bottom, 16 * PhoneLayout.metricScale)
                    }
                }
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

    /// 카드를 렌더할 가치가 있는 상태인지. idle 과 failed 는 숨김(지원/생성 실패 케이스 동일하게 처리).
    private var shouldShowDescription: Bool {
        switch store.descriptionStatus {
        case .loading, .loaded: return true
        case .idle, .failed: return false
        }
    }

    @ViewBuilder
    private var descriptionCard: some View {
        let ink = Color.appText
        let surface = Color.vhsSurface
        VStack(alignment: .leading, spacing: 10 * PhoneLayout.metricScale) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.vhsMagenta)
                Text(L10n.aiReportTitle)
                    .font(.app(13))
                    .fontWeight(.heavy)
                    .foregroundStyle(ink.opacity(0.7))
                    .textCase(.uppercase)
            }

            switch store.descriptionStatus {
            case .loading:
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(ink)
                    Text(L10n.aiReportLoading)
                        .font(.app(14))
                        .foregroundStyle(ink.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            case .loaded(let text):
                Text(text)
                    .font(.app(15))
                    .foregroundStyle(ink)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .idle, .failed:
                EmptyView()
            }
        }
        .padding(14 * PhoneLayout.metricScale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(surface)
        .overlay(
            Rectangle()
                .stroke(ink, lineWidth: 1.5)
        )
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
            formattedScoreText: L10n.formattedScore(totalScore)
        )
        shareImage = img
        showShareSheet = img != nil
    }
}
