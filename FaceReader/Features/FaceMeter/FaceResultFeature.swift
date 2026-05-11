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
        /// Snapshot used for the wanted poster (TCA-visible so the result screen always redraws).
        public var posterImageData: Data?

        public init(box: SessionBox, posterImageData: Data? = nil) {
            self.box = box
            self.posterImageData = posterImageData
        }
    }

    public enum Action: Equatable {
        case onAppear
        case dismissTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismiss
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.nicknameLine = L10n.anonymousMonster
                return .none

            case .dismissTapped:
                return .send(.delegate(.dismiss))

            case .delegate:
                return .none
            }
        }
    }
}
