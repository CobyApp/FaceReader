//
//  AppTheme.swift
//  FaceReader
//

import FaceReaderLocalization
import SwiftUI
import UIKit

extension Color {
    public static let appText = Color(uiColor: .vhsInk)
    public static let appBackground = Color(uiColor: .vhsBase)
    public static let appBrown = Color(hex: 0x4B3E36)

    public static let vhsBase = Color(uiColor: .vhsBase)
    public static let vhsSurface = Color(uiColor: .vhsSurface)
    public static let vhsInk = Color(uiColor: .vhsInk)
    public static let vhsRed = Color(uiColor: .vhsRed)
    public static let vhsCyan = Color(uiColor: .vhsCyan)
    public static let vhsMagenta = Color(uiColor: .vhsMagenta)
}

extension UIColor {
    /// 단일 톤 팔레트 — 시스템 라이트/다크 모드와 무관하게 항상 동일.
    public static let vhsBase = UIColor(hex: "#0a0808")
    public static let vhsSurface = UIColor(hex: "#1a1414")
    public static let vhsInk = UIColor(hex: "#f4e9d3")
    public static let vhsRed = UIColor(hex: "#d6433a")
    public static let vhsCyan = UIColor(hex: "#48b8c4")
    public static let vhsMagenta = UIColor(hex: "#c34d8a")

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
        return appUnscaled(s)
    }

    /// Same font family selection but no per-device scaling. Used for fixed-size canvases (e.g., 현상금 포스터)
    /// so output looks identical on every iPhone.
    public static func posterApp(_ size: CGFloat) -> Font {
        return appUnscaled(size)
    }

    private static func appUnscaled(_ size: CGFloat) -> Font {
        let candidates: [String] = {
            switch LanguageResolver.effectiveResourceTag() {
            case "ja": return japaneseAppFontCandidates
            default: return latinKoreanAppFontCandidates
            }
        }()
        for name in candidates where UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        }
        return Font.system(size: size, weight: .semibold, design: .rounded)
    }
}
