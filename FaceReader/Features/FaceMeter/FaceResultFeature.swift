//
//  FaceResultFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderCore
import FaceReaderLocalization
import Foundation

@Reducer
public struct FaceResultFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var box: SessionBox
        public var nicknameLine: String = ""

        public init(box: SessionBox) {
            self.box = box
        }
    }

    public enum Action: Equatable {
        case onAppear
        case explanationTapped
        case dismissTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismiss
            case showHelp
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.nicknameLine = L10n.anonymousMonster
                return .none

            case .explanationTapped:
                return .send(.delegate(.showHelp))

            case .dismissTapped:
                return .send(.delegate(.dismiss))

            case .delegate:
                return .none
            }
        }
    }
}
