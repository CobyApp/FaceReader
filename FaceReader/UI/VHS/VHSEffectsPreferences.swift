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

    @Published public var nickname: String {
        didSet { UserDefaults.standard.set(nickname, forKey: Self.nicknameKey) }
    }

    private static let reducedKey = "vhs_effects_reduced"
    private static let landmarksKey = "show_face_landmarks"
    private static let nicknameKey = "user_nickname"

    private init() {
        self.reducedEffects = UserDefaults.standard.bool(forKey: Self.reducedKey)
        // showLandmarks 는 기본 true. UserDefaults 미설정 시 true 를 유지하려고 별도 처리.
        if UserDefaults.standard.object(forKey: Self.landmarksKey) == nil {
            self.showLandmarks = true
        } else {
            self.showLandmarks = UserDefaults.standard.bool(forKey: Self.landmarksKey)
        }
        self.nickname = UserDefaults.standard.string(forKey: Self.nicknameKey) ?? ""
    }
}
