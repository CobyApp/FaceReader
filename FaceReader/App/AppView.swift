//
//  AppView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack {
            RankingView(
                store: store.scope(state: \.ranking, action: \.ranking),
                onMonsterTap: { store.send(.rankingRowTapped($0)) }
            )
            .navigationTitle(L10n.mainRankingTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            store.send(.helpTapped)
                        } label: {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundStyle(Color.appText)
                        }
                        Button {
                            store.send(.editNicknameTapped)
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(Color.appText)
                        }
                        Button {
                            store.send(.cameraTapped)
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(Color.appText)
                        }
                    }
                }
            }
            .toolbarBackground(Color.appBackground, for: .navigationBar)
        }
        .tint(Color.appText)
        .sheet(item: $store.scope(state: \.nicknameSheet, action: \.nicknameSheet)) { sheetStore in
            NavigationStack {
                NicknameView(store: sheetStore)
            }
        }
        .sheet(item: $store.scope(state: \.helpSheet, action: \.helpSheet)) { sheetStore in
            HelpView(store: sheetStore)
        }
        .sheet(item: $store.scope(state: \.monsterPaper, action: \.monsterPaper)) { sheetStore in
            NavigationStack {
                MonsterPaperView(store: sheetStore)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { store.faceCapture != nil },
            set: { if !$0 { store.send(.faceCaptureDismissed) } }
        )) {
            if let box = store.faceCapture {
                NavigationStack {
                    FaceCaptureView(
                        box: box,
                        onCommitted: { store.send(.faceCaptureCommitted(box)) },
                        onEditNickname: { store.send(.editNicknameTapped) },
                        onDismiss: { store.send(.faceCaptureDismissed) }
                    )
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { store.faceResult != nil },
            set: { if !$0 { store.send(.faceResultDismissed) } }
        )) {
            IfLetStore(store.scope(state: \.faceResult, action: \.faceResult)) { resultStore in
                NavigationStack {
                    FaceResultView(store: resultStore)
                }
            }
        }
    }
}
