//
//  AppFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderCore
import FaceReaderLocalization
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var sessionBox = SessionBox()
        var faceResult: FaceResultFeature.State?
        var isShowingHelp = false
        var settingsPresented = false
        var languageRefreshToken = 0
    }

    enum Action: Equatable {
        case faceCaptureCommitted
        case faceResult(FaceResultFeature.Action)
        case helpFinished
        case settingsButtonTapped
        case settingsDismissed
        case languagePreferenceSaved(String?)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .faceCaptureCommitted:
                state.faceResult = FaceResultFeature.State(box: state.sessionBox)
                return .none

            case .helpFinished:
                state.isShowingHelp = false
                state.sessionBox = SessionBox()
                return .none

            case .faceResult(.delegate(.dismiss)):
                state.faceResult = nil
                state.sessionBox = SessionBox()
                return .none

            case .faceResult(.delegate(.showHelp)):
                state.faceResult = nil
                state.isShowingHelp = true
                return .none

            case .faceResult:
                return .none

            case .settingsButtonTapped:
                state.settingsPresented = true
                return .none

            case .settingsDismissed:
                state.settingsPresented = false
                return .none

            case let .languagePreferenceSaved(code):
                LanguageResolver.saveOverrideTag(code)
                state.languageRefreshToken += 1
                state.settingsPresented = false
                return .none
            }
        }
        .ifLet(\.faceResult, action: \.faceResult) {
            FaceResultFeature()
        }
    }
}
