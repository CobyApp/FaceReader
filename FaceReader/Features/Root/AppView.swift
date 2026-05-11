//
//  AppView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import FaceReaderUI
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack {
            Group {
                if store.isShowingHelp {
                    HelpView {
                        store.send(.helpFinished)
                    }
                } else if let resultStore = store.scope(state: \.faceResult, action: \.faceResult) {
                    FaceResultView(store: resultStore)
                } else {
                    FaceCaptureView(
                        box: store.sessionBox,
                        onCommitted: { store.send(.faceCaptureCommitted(posterImageData: $0)) },
                        onSettingsTapped: { store.send(.settingsButtonTapped) },
                        onHelpTapped: { store.send(.helpButtonTapped) }
                    )
                }
            }
            .id(store.languageRefreshToken)
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Color.vhsInk)
        .background(Color.vhsBase.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: Binding(
            get: { store.settingsPresented },
            set: { presented in
                if !presented { store.send(.settingsDismissed) }
            }
        )) {
            SettingsView(
                currentOverride: LanguageResolver.storedOverrideTag,
                onSelect: { store.send(.languagePreferenceSaved($0)) },
                onCancel: { store.send(.settingsDismissed) }
            )
        }
    }
}
