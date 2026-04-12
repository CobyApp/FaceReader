//
//  NicknamePreferences.swift
//  FaceReader
//

import Foundation

struct NicknamePreferences: Sendable {
    private let loadImpl: @Sendable () -> String?
    private let saveImpl: @Sendable (String) -> Void

    init(load: @escaping @Sendable () -> String?, save: @escaping @Sendable (String) -> Void) {
        self.loadImpl = load
        self.saveImpl = save
    }

    func load() -> String? {
        loadImpl()
    }

    func save(_ nickname: String) {
        saveImpl(nickname)
    }

    static let userDefaults = NicknamePreferences(
        load: { UserDefaults.standard.string(forKey: "nickname") },
        save: { UserDefaults.standard.set($0, forKey: "nickname") }
    )
}
