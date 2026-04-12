//
//  FaceResultFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import Foundation
import UIKit

@Reducer
struct FaceResultFeature {
    @ObservableState
    struct State: Equatable {
        var box: SessionBox
        var nicknameLine: String = ""
        var isWorking = false
        var showRegisterDone = false
    }

    enum Action: Equatable {
        case onAppear
        case registerTapped
        case registerResponse
        case dismissToast
        case dismissTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case dismiss
            case registered
        }
    }

    @Dependency(\.monsterMutationClient) private var mutationClient
    @Dependency(\.nicknamePreferences) private var nicknamePreferences

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let nick = nicknamePreferences.load() ?? ""
                state.nicknameLine = nick.isEmpty ? L10n.anonymousMonster : L10n.nicknameDecorated(nick)
                return .none

            case .registerTapped:
                guard let image = state.box.session.cartoonImage else { return .none }
                state.isWorking = true
                let nick = nicknamePreferences.load()?.trimmingCharacters(in: .whitespacesAndNewlines)
                let resolvedNick = (nick?.isEmpty ?? true) ? L10n.anonymousMonster : nick!
                let grade = state.box.session.grade
                let score = state.box.session.totalScore
                return .run { send in
                    await mutationClient.createMonster(resolvedNick, image, grade, score)
                    await send(.registerResponse)
                }

            case .registerResponse:
                state.isWorking = false
                state.showRegisterDone = true
                return .send(.delegate(.registered))

            case .dismissToast:
                state.showRegisterDone = false
                return .none

            case .dismissTapped:
                return .send(.delegate(.dismiss))

            case .delegate:
                return .none
            }
        }
    }
}
