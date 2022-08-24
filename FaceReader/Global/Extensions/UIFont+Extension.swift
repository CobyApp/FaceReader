//
//  UIFont+Extension.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/24.
//

import UIKit

enum AppFontName: String {
    case regular = "SangSangAnt"
}

extension UIFont {
    static func font(_ style: AppFontName, ofSize size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size)!
    }
}
