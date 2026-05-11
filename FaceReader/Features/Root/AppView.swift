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
                        onCommitted: { store.send(.faceCaptureCommitted(posterImageData: $0)) }
                    )
                }
            }
            .id(store.languageRefreshToken)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.settingsButtonTapped)
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.vhsBase)
                                .frame(width: 36 * PhoneLayout.metricScale, height: 28 * PhoneLayout.metricScale)
                            Rectangle()
                                .stroke(Color.vhsInk, lineWidth: 2)
                                .frame(width: 36 * PhoneLayout.metricScale, height: 28 * PhoneLayout.metricScale)
                            Text("VHS")
                                .font(.app(10))
                                .fontWeight(.black)
                                .foregroundStyle(Color.vhsInk)
                        }
                    }
                    .accessibilityLabel(L10n.settingsTitle)
                }
            }
        }
        .tint(Color.vhsInk)
        .background(Color.vhsBase.ignoresSafeArea())
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
