//
//  FaceResultView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import SwiftUI

struct FaceResultView: View {
    @Bindable var store: StoreOf<FaceResultFeature>

    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            MonsterPosterView(
                faceImage: store.box.session.cartoonImage,
                nicknameLine: store.nicknameLine,
                grade: store.box.session.grade,
                totalScore: store.box.session.totalScore
            )
            .frame(maxWidth: .infinity)
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
                store.send(.registerTapped)
            } label: {
                Text(L10n.btnRegisterMonster)
                    .font(.app(22))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.appText.opacity(0.35))
                    .foregroundStyle(Color.appText)
            }
            .disabled(store.isWorking)
        }
        .overlay {
            if store.isWorking {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
        .alert(L10n.toastRegisterDone, isPresented: Binding(
            get: { store.showRegisterDone },
            set: { if !$0 { store.send(.dismissToast) } }
        )) {
            Button(L10n.btnOk, role: .cancel) { store.send(.dismissToast) }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityView(activityItems: [shareImage])
            }
        }
    }

    private func prepareShare() {
        let img = PosterImageRenderer.render(
            faceImage: store.box.session.cartoonImage,
            nicknameLine: store.nicknameLine,
            grade: store.box.session.grade,
            totalScore: store.box.session.totalScore
        )
        shareImage = img
        showShareSheet = img != nil
    }
}
