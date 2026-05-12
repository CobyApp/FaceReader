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
    /// 한국어 본문 — 번들 손글씨 우선.
    private static let koreanAppFontCandidates: [String] = [
        "SangSangAnt",
    ]

    /// 영어 본문 — iOS 시스템 코믹/손글씨 폰트.
    private static let englishAppFontCandidates: [String] = [
        "ChalkboardSE-Bold",
        "MarkerFelt-Wide",
        "Noteworthy-Bold",
        "BradleyHandITCTT-Bold",
    ]

    /// 일본어 본문 — 손글씨 톤(Klee) → 둥글한 츠쿠시 → 히라기노 마루 → 번들 폴백.
    /// Klee 와 TsukushiAMaruGothic 은 iOS 시스템 번들 (사용자 디바이스에 따라 가용 여부 다름).
    private static let japaneseAppFontCandidates: [String] = [
        "Klee-Medium",                          // 손글씨 풍 — 매우 귀여움
        "Klee-DemiBold",
        "TsukushiAMaruGothic-Bold",             // 둥글둥글 진한 톤
        "TsukushiAMaruGothic-Regular",
        "HiraMaruProN-W4",                      // 시스템 폴백
        "ToppanBunkyuMidashiGothicStdN-ExtraBold",
        "KosugiMaru-Regular",                   // 번들 최종 폴백
    ]

    /// 포스터 WANTED — 언어 무관, 마커펜/손글씨 톤.
    private static let posterDisplayCandidates: [String] = [
        "MarkerFelt-Wide",
        "ChalkboardSE-Bold",
        "Noteworthy-Bold",
        "BradleyHandITCTT-Bold",
    ]

    /// 포스터 현상금 ($1,234,567) — 타이프라이터/스탬프 톤으로 'official document' 느낌.
    private static let posterBountyCandidates: [String] = [
        "AmericanTypewriter-Bold",
        "AmericanTypewriter-Semibold",
        "Courier-Bold",
        "Menlo-Bold",
    ]

    /// 디바이스 폭에 따라 스케일된 본문 폰트. 활성 언어 기준.
    public static func app(_ size: CGFloat) -> Font {
        app(size, languageTag: LanguageResolver.effectiveResourceTag())
    }

    /// 명시한 언어 태그(ko/ja/en) 기준 본문 폰트. 활성 언어와 무관 — 설정 화면처럼
    /// 라벨 문자열이 그 자체로 특정 언어인 경우(예: '日本語') 그 언어용 캐스케이드로 그림.
    public static func app(_ size: CGFloat, languageTag: String?) -> Font {
        appCascade(
            size: PhoneLayout.scaledFontSize(size),
            candidates: candidates(for: languageTag)
        )
    }

    /// 디바이스 무관 고정 크기 — 포스터 본문 (닉네임/설명) 용. 활성 언어 캐스케이드.
    public static func posterApp(_ size: CGFloat) -> Font {
        appCascade(size: size, candidates: candidates(for: LanguageResolver.effectiveResourceTag()))
    }

    /// 디바이스 무관 고정 크기 — 포스터 WANTED 전용. 언어 무관 코믹 마커펜 톤.
    public static func posterDisplay(_ size: CGFloat) -> Font {
        appCascade(size: size, candidates: posterDisplayCandidates, fallbackWeight: .heavy)
    }

    /// 디바이스 무관 고정 크기 — 포스터 현상금 ($) 전용. 타이프라이터 톤.
    public static func posterBounty(_ size: CGFloat) -> Font {
        appCascade(size: size, candidates: posterBountyCandidates, fallbackWeight: .black)
    }

    private static func candidates(for tag: String?) -> [String] {
        switch tag {
        case "ja": return japaneseAppFontCandidates
        case "en": return englishAppFontCandidates
        case "ko": return koreanAppFontCandidates
        default:
            // 시스템과 동일 등 — 활성 언어 기준.
            return candidates(for: LanguageResolver.effectiveResourceTag())
        }
    }

    private static func appCascade(size: CGFloat, candidates: [String], fallbackWeight: Font.Weight = .semibold) -> Font {
        for name in candidates where UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        }
        return Font.system(size: size, weight: fallbackWeight, design: .rounded)
    }
}
