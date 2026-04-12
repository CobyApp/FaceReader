//
//  NicknameView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import SwiftUI

struct NicknameView: View {
    @Bindable var store: StoreOf<NicknameFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.nicknameTitle)
                .font(.app(22))
                .foregroundStyle(Color.appText)

            TextField(L10n.nicknamePlaceholder, text: $store.text.sending(\.textChanged))
                .font(.app(20))
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 10)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appText.opacity(0.45), lineWidth: 1)
                )

            Spacer()

            Button {
                store.send(.completeTapped)
            } label: {
                Text(L10n.btnComplete)
                    .font(.app(20))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appText.opacity(0.2))
                    .foregroundStyle(Color.appText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color.appBackground)
        .onAppear { store.send(.onAppear) }
        .alert(
            L10n.toastNicknameInvalid,
            isPresented: Binding(
                get: { store.validationMessage != nil },
                set: { if !$0 { store.send(.validationDismissed) } }
            )
        ) {
            Button(L10n.btnOk, role: .cancel) { store.send(.validationDismissed) }
        }
    }
}
