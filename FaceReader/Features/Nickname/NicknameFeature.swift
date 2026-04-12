//
//  NicknameFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import Foundation

@Reducer
struct NicknameFeature {
    @ObservableState
    struct State: Equatable {
        var text = ""
        var validationMessage: String?
    }

    enum Action: Equatable {
        case onAppear
        case textChanged(String)
        case completeTapped
        case validationDismissed
    }

    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.nicknamePreferences) private var nicknamePreferences

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.text = nicknamePreferences.load() ?? ""
                return .none

            case let .textChanged(value):
                state.text = value
                return .none

            case .completeTapped:
                let trimmed = state.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    state.validationMessage = L10n.toastNicknameInvalid
                    return .none
                }
                nicknamePreferences.save(trimmed)
                return .run { _ in
                    await dismiss()
                }

            case .validationDismissed:
                state.validationMessage = nil
                return .none
            }
        }
    }
}
