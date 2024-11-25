//
//  UIColor+Extension.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/29.
//

import UIKit

extension UIColor {
    static var mainText: UIColor {
        return UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#eeeeee")
                : UIColor(hex: "#111111")
        }
    }
    
    static var mainBackground: UIColor {
        return UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#111111")
                : UIColor(hex: "#eeeeee")
        }
    }
    
    static var mainBlack: UIColor {
        return UIColor(hex: "#4B3E36")
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}
