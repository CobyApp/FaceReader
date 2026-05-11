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
        didSet {
            UserDefaults.standard.set(reducedEffects, forKey: Self.reducedKey)
        }
    }

    private static let reducedKey = "vhs_effects_reduced"

    private init() {
        self.reducedEffects = UserDefaults.standard.bool(forKey: Self.reducedKey)
    }
}
