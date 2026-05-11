//
//  VHSEffectsPreferences.swift
//  FaceReader
//

import Combine
import SwiftUI

@MainActor
public final class VHSEffectsPreferences: ObservableObject {
    public static let shared = VHSEffectsPreferences()

    @Published public var reducedEffects: Bool {
        didSet { UserDefaults.standard.set(reducedEffects, forKey: Self.reducedKey) }
    }

    @Published public var showLandmarks: Bool {
        didSet { UserDefaults.standard.set(showLandmarks, forKey: Self.landmarksKey) }
    }

    private static let reducedKey = "vhs_effects_reduced"
    private static let landmarksKey = "show_face_landmarks"

    private init() {
        self.reducedEffects = UserDefaults.standard.bool(forKey: Self.reducedKey)
        if UserDefaults.standard.object(forKey: Self.landmarksKey) == nil {
            self.showLandmarks = true
        } else {
            self.showLandmarks = UserDefaults.standard.bool(forKey: Self.landmarksKey)
        }
    }
}
