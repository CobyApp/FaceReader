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

    public var body: some View {
        ScrollView {
            MonsterPosterView(
                faceImage: posterUIImage,
                nicknameLine: store.nicknameLine,
                posterWantedText: L10n.posterWanted,
                posterDeadOrAliveText: L10n.posterDeadOrAlive,
                gradeLineText: L10n.gradeLine(for: store.box.session.grade),
                formattedScoreText: L10n.formattedScore(store.box.session.totalScore)
            )
            .frame(maxWidth: .infinity)
            .glitchTracking(active: revealActive, intensity: revealIntensity, duration: 0.6)
        }
        .background(Color.appBackground)
        .navigationTitle(L10n.resultScreenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    store.send(.dismissTapped)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appText)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(L10n.actionShare) {
                    prepareShare()
                }
                .foregroundStyle(Color.appText)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                store.send(.explanationTapped)
            } label: {
                Text(L10n.btnMonsterExplanation)
                    .font(.app(23))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22 * PhoneLayout.metricScale)
                    .background(Color.appText.opacity(0.35))
                    .foregroundStyle(Color.appText)
            }
        }
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

    private var revealIntensity: Double {
        // 등급에 따라 약하게 (wolf=0 → god=4 ⇒ 0.15~0.55)
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
            nicknameLine: store.nicknameLine,
            posterWantedText: L10n.posterWanted,
            posterDeadOrAliveText: L10n.posterDeadOrAlive,
            gradeLineText: L10n.gradeLine(for: grade),
            formattedScoreText: L10n.formattedScore(totalScore)
        )
        shareImage = img
        showShareSheet = img != nil
    }
}
