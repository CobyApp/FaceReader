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
    /// Japanese UI 본문 — 가능하면 ヒラギノ丸ゴ (iOS 시스템 둥근 고딕) 우선, 번들 KosugiMaru 폴백.
    /// 둘 다 평범한 office 톤보다는 살짝 친근한 둥근 고딕.
    private static let japaneseAppFontCandidates: [String] = [
        "HiraMaruProN-W4",          // ヒラギノ丸ゴ ProN W4 — 둥글둥글 귀여움
        "ToppanBunkyuMidashiGothicStdN-ExtraBold",
        "TsukushiAMaruGothic-Bold",
        "KosugiMaru-Regular",       // 번들 폴백
    ]

    /// Korean / English UI 본문 — SangSangAnt (번들 손글씨) 우선.
    private static let latinKoreanAppFontCandidates: [String] = [
        "SangSangAnt",
        "ChalkboardSE-Bold",        // 영문 폴백, 코믹/둥글한 톤
        "MarkerFelt-Wide",
        "Noteworthy-Bold",
    ]

    /// 포스터의 WANTED · 현상금 같은 라틴/숫자 디스플레이 — 언어 무관 항상 동일.
    /// 코믹 wanted-poster 톤 (마커펜/분필 손글씨).
    private static let posterDisplayCandidates: [String] = [
        "MarkerFelt-Wide",
        "ChalkboardSE-Bold",
        "Noteworthy-Bold",
        "BradleyHandITCTT-Bold",
    ]

    /// 디바이스 폭에 따라 스케일된 본문 폰트. 언어별 캐스케이드.
    public static func app(_ size: CGFloat) -> Font {
        appCascade(size: PhoneLayout.scaledFontSize(size), candidates: bodyCandidatesForActiveLanguage())
    }

    /// 디바이스 무관 고정 크기 — 포스터 본문 (닉네임/설명) 용. 언어별 캐스케이드.
    public static func posterApp(_ size: CGFloat) -> Font {
        appCascade(size: size, candidates: bodyCandidatesForActiveLanguage())
    }

    /// 디바이스 무관 고정 크기 — 포스터 WANTED · 현상금 전용. 언어 무관 단일 폰트.
    public static func posterDisplay(_ size: CGFloat) -> Font {
        appCascade(size: size, candidates: posterDisplayCandidates, fallbackWeight: .heavy)
    }

    private static func bodyCandidatesForActiveLanguage() -> [String] {
        switch LanguageResolver.effectiveResourceTag() {
        case "ja": return japaneseAppFontCandidates
        default: return latinKoreanAppFontCandidates
        }
    }

    private static func appCascade(size: CGFloat, candidates: [String], fallbackWeight: Font.Weight = .semibold) -> Font {
        for name in candidates where UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        }
        return Font.system(size: size, weight: fallbackWeight, design: .rounded)
    }
}
