//
//  FaceReaderApp.swift
//  FaceReader
//

import FaceReaderFeatures
import SwiftUI

@main
struct FaceReaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            FaceReaderAppRoot()
        }
    }
}
