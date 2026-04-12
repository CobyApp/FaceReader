//
//  AppTheme.swift
//  FaceReader
//

import FaceReaderLocalization
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
    /// Japanese UI: rounded gothic (bundled). Matches `LanguageResolver` active tag `ja`.
    private static let japaneseAppFontCandidates: [String] = [
        "KosugiMaru-Regular",
        "MPLUSRounded1c-Bold",
        "MPLUSRounded1c-Medium",
        "ZenMaruGothic-Bold",
        "ZenMaruGothic-Medium",
        "YuseiMagic-Regular",
        "SangSangAnt",
    ]

    /// English / Korean UI: SangSangAnt first; optional extra faces if not bundled.
    private static let latinKoreanAppFontCandidates: [String] = [
        "SangSangAnt",
        "MPLUSRounded1c-Bold",
        "MPLUSRounded1c-Medium",
        "ZenMaruGothic-Bold",
        "ZenMaruGothic-Medium",
        "YuseiMagic-Regular",
    ]

    /// Custom display font scaled for the current iPhone width. Font family follows active app language (`LanguageResolver`).
    public static func app(_ size: CGFloat) -> Font {
        let s = PhoneLayout.scaledFontSize(size)
        let candidates: [String] = {
            switch LanguageResolver.effectiveResourceTag() {
            case "ja": return japaneseAppFontCandidates
            default: return latinKoreanAppFontCandidates
            }
        }()
        for name in candidates where UIFont(name: name, size: s) != nil {
            return Font.custom(name, size: s)
        }
        return Font.system(size: s, weight: .semibold, design: .rounded)
    }
}
