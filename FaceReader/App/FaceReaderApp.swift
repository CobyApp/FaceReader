//
//  FaceReaderApp.swift
//  FaceReader
//

import ComposableArchitecture
import SwiftUI

@main
struct FaceReaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
