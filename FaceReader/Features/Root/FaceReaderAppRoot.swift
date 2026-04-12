//
//  FaceReaderAppRoot.swift
//  FaceReader
//

import ComposableArchitecture
import SwiftUI

/// App entry UI + store; keeps the `FaceReader` app target free of TCA / CasePaths package links.
public struct FaceReaderAppRoot: View {
    public init() {}

    public var body: some View {
        AppView(
            store: Store(initialState: AppFeature.State()) {
                AppFeature()
            }
        )
    }
}
