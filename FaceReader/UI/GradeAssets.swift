//
//  GradeAssets.swift
//  FaceReader
//

import SwiftUI

enum GradeAssets {
    static func imageName(for grade: Int) -> String {
        switch grade {
        case 0: return "wolf"
        case 1: return "tiger"
        case 2: return "demon"
        case 3: return "dragon"
        case 4: return "god"
        default: return "wolf"
        }
    }
}
