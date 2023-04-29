//
//  Model.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import Foundation

import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, nickname, password, imageUrl: String
    let gradeIndex, score: Int
}
