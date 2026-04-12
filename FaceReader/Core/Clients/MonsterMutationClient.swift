//
//  MonsterMutationClient.swift
//  FaceReader
//

import UIKit

struct MonsterMutationClient: Sendable {
    var createMonster: @Sendable (_ nickname: String, _ image: UIImage, _ grade: Int, _ score: Int) async -> Void
    var deleteMonster: @Sendable (_ monster: Monster) async -> Void
}
