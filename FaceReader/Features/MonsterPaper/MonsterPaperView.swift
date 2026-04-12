//
//  MonsterPaperView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import SwiftUI

struct MonsterPaperView: View {
    @Bindable var store: StoreOf<MonsterPaperFeature>

    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            AsyncImage(url: URL(string: store.monster.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Text(L10n.emptyRankList)
                        .foregroundStyle(Color.appText)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .background(Color.appBackground)
        .navigationTitle(L10n.monsterPaperTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(L10n.actionShare) {
                    Task { await loadShareImage() }
                }
                .foregroundStyle(Color.appText)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                store.send(.deleteTapped)
            } label: {
                Text(L10n.btnDeleteMonster)
                    .font(.app(22))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.appText.opacity(0.35))
                    .foregroundStyle(Color.appText)
            }
            .disabled(store.isDeleting)
        }
        .overlay {
            if store.isDeleting {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                }
            }
        }
        .confirmationDialog(
            L10n.alertDeleteTitle,
            isPresented: Binding(
                get: { store.showDeleteConfirm },
                set: { if !$0 { store.send(.deleteConfirmDismissed) } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.btnOk, role: .destructive) {
                store.send(.deleteConfirmed)
            }
            Button(L10n.btnCancel, role: .cancel) {
                store.send(.deleteConfirmDismissed)
            }
        } message: {
            Text(L10n.alertDeleteBody)
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityView(activityItems: [shareImage])
            }
        }
    }

    private func loadShareImage() async {
        guard let url = URL(string: store.monster.imageUrl) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    shareImage = image
                    showShareSheet = true
                }
            }
        } catch {
            // Ignore; user can retry.
        }
    }
}
