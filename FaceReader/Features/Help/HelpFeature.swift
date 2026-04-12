//
//  HelpFeature.swift
//  FaceReader
//

import ComposableArchitecture
import Foundation

@Reducer
struct HelpFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {
        case closeTapped
    }

    @Dependency(\.dismiss) private var dismiss

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .closeTapped:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
