//
//  Monster.swift
//  FaceReader
//

import Foundation

struct Monster: Codable, Identifiable, Equatable, Sendable {
    let uid: String
    let nickname: String
    let imageUrl: String
    let grade: Int
    let score: Int
    let year: String
    let month: String
    let day: String

    var id: String { uid }
}

extension Date {
    var dateToString: (year: String, month: String, day: String) {
        let year = Calendar.current.component(.year, from: self)
        let month = Calendar.current.component(.month, from: self)
        let day = Calendar.current.component(.day, from: self)
        return ("\(year)", "\(month)", "\(day)")
    }
}
