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
    @State private var isEditingNickname = false
    @State private var nicknameDraft: String = ""

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
                    formattedScoreText: L10n.formattedScore(store.box.session.totalScore)
                )
                .frame(maxWidth: .infinity)
                .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            actionBar
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
        .alert(L10n.nicknameEditTitle, isPresented: $isEditingNickname) {
            TextField(L10n.nicknameEditPlaceholder, text: $nicknameDraft)
                .textInputAutocapitalization(.never)
            Button(L10n.btnOk) {
                let trimmed = nicknameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                prefs.nickname = trimmed
            }
            Button(L10n.btnCancel, role: .cancel) {}
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
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var actionBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.appText.opacity(0.18))
                .frame(height: 1)

            HStack(spacing: 0) {
                actionButton(
                    icon: "person.text.rectangle",
                    label: L10n.nicknameTitle
                ) {
                    nicknameDraft = prefs.nickname
                    isEditingNickname = true
                }

                Rectangle()
                    .fill(Color.appText.opacity(0.18))
                    .frame(width: 1)
                    .padding(.vertical, 12)

                actionButton(
                    icon: "square.and.arrow.up",
                    label: L10n.actionShare
                ) {
                    prepareShare()
                }

                Rectangle()
                    .fill(Color.appText.opacity(0.18))
                    .frame(width: 1)
                    .padding(.vertical, 12)

                actionButton(
                    icon: "info.circle",
                    label: L10n.btnMonsterExplanation
                ) {
                    store.send(.explanationTapped)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.vhsSurface)
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Color.appText)
            Text(label)
                .font(.app(12))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.appText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { action() }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(label)
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
