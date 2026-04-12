//
//  AppTheme.swift
//  FaceReader
//

import SwiftUI
import UIKit

extension Color {
    public static let appText = Color(uiColor: .appMainText)
    public static let appBackground = Color(uiColor: .appMainBackground)
    public static let appBrown = Color(hex: 0x4B3E36)
}

extension UIColor {
    public static var appMainText: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#eeeeee")
                : UIColor(hex: "#111111")
        }
    }

    public static var appMainBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#111111")
                : UIColor(hex: "#eeeeee")
        }
    }

    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        precondition(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension Color {
    public init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex & 0xFF0000) >> 16) / 255
        let g = Double((hex & 0x00FF00) >> 8) / 255
        let b = Double(hex & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

extension Font {
    /// Custom display font scaled for the current iPhone width.
    public static func app(_ size: CGFloat) -> Font {
        let s = PhoneLayout.scaledFontSize(size)
        if UIFont(name: "SangSangAnt", size: s) != nil {
            return Font.custom("SangSangAnt", size: s)
        }
        return Font.system(size: s, weight: .semibold, design: .rounded)
    }
}
