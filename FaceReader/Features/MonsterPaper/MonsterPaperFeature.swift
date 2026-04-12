//
//  MonsterPaperFeature.swift
//  FaceReader
//

import ComposableArchitecture
import Foundation

@Reducer
struct MonsterPaperFeature {
    @ObservableState
    struct State: Equatable {
        var monster: Monster
        var isDeleting = false
        var showDeleteConfirm = false
    }

    enum Action: Equatable {
        case deleteTapped
        case deleteConfirmDismissed
        case deleteConfirmed
        case deleteFinished
        case delegate(Delegate)

        enum Delegate: Equatable {
            case deleted
        }
    }

    @Dependency(\.monsterMutationClient) private var mutationClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .deleteTapped:
                state.showDeleteConfirm = true
                return .none

            case .deleteConfirmDismissed:
                state.showDeleteConfirm = false
                return .none

            case .deleteConfirmed:
                state.showDeleteConfirm = false
                state.isDeleting = true
                let monster = state.monster
                return .run { send in
                    await mutationClient.deleteMonster(monster)
                    await send(.deleteFinished)
                }

            case .deleteFinished:
                state.isDeleting = false
                return .send(.delegate(.deleted))

            case .delegate:
                return .none
            }
        }
    }
}
