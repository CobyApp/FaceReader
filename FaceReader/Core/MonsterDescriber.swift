//
//  MonsterDescriber.swift
//  FaceReader
//

import Foundation
import FoundationModels

/// Apple Intelligence (Foundation Models) on-device 모델로 원펀맨 세계관 풍의 빌런 이름 + 도감 한 줄 동시 생성.
public actor MonsterDescriber {
    public enum DescriptionLanguage: String, Sendable {
        case ko, ja, en
    }

    public enum DescribeError: Error, Sendable {
        case unavailable(reason: String)
        case guardrailBlocked
        case generationFailed(String)
    }

    @Generable
    public struct MonsterReport: Equatable, Sendable {
        @Guide(description: "Villain codename: one short word.")
        public var codename: String

        @Guide(description: "One funny sentence describing the monster.")
        public var description: String
    }

    public struct Input: Sendable {
        public let grade: Int
        public let language: DescriptionLanguage
        public let ratios: FaceMeasureSession.RatioSnapshot?

        public init(grade: Int, language: DescriptionLanguage, ratios: FaceMeasureSession.RatioSnapshot? = nil) {
            self.grade = grade
            self.language = language
            self.ratios = ratios
        }
    }

    public init() {}

    public static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        default: return false
        }
    }

    public static var unavailableReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence가 꺼져있어요. 설정 → Apple Intelligence에서 켠 뒤 다시 시도해주세요."
            case .deviceNotEligible:
                return "이 기기는 Apple Intelligence를 지원하지 않아요. (iPhone 15 Pro 이상)"
            case .modelNotReady:
                return "Apple Intelligence 모델을 다운로드 중이에요. 잠시 후 다시 열어주세요."
            @unknown default:
                return "Apple Intelligence를 지금 사용할 수 없어요."
            }
        @unknown default:
            return "Apple Intelligence 상태를 확인할 수 없어요."
        }
    }

    public func generate(_ input: Input) async throws -> MonsterReport {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(let reason):
            throw DescribeError.unavailable(reason: String(describing: reason))
        @unknown default:
            throw DescribeError.unavailable(reason: "unknown")
        }

        let session = LanguageModelSession(instructions: { Self.systemInstructions(language: input.language) })
        let prompt = Self.userPrompt(input)
        do {
            let response = try await session.respond(to: prompt, generating: MonsterReport.self)
            let raw = response.content
            return MonsterReport(
                codename: Self.sanitizeCodename(raw.codename),
                description: Self.clampDescription(Self.sanitize(raw.description), language: input.language)
            )
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .guardrailViolation:
                throw DescribeError.guardrailBlocked
            default:
                throw DescribeError.generationFailed(String(describing: error))
            }
        } catch {
            throw DescribeError.generationFailed(String(describing: error))
        }
    }

    private static func sanitize(_ raw: String) -> String {
        var text = raw
        for token in ["**", "__", "~~", "```", "`"] {
            text = text.replacingOccurrences(of: token, with: "")
        }
        text = text.replacingOccurrences(of: "*", with: "")
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let openClose: [(Character, Character)] = [("\"", "\""), ("“", "”"), ("「", "」"), ("『", "』")]
        if let first = trimmed.first, let last = trimmed.last,
           openClose.contains(where: { $0.0 == first && $0.1 == last }) {
            return String(trimmed.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }

    /// 포스터 한 줄에 들어가도록 짧게 cap. 줄임표(…) 안 붙임 — 사용자가 끝까지 보길 원함.
    /// ko/ja: 30자, en: 60자.
    public static func clampDescription(_ raw: String, language: DescriptionLanguage) -> String {
        let limit: Int = (language == .en) ? 60 : 30
        let collapsed = raw
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        // 단어 경계에서 끊되, 줄임표 없이 깔끔하게 마무리.
        let head = String(collapsed.prefix(limit))
        if let lastSpace = head.lastIndex(of: " ") {
            return String(head[..<lastSpace]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return head.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func sanitizeCodename(_ raw: String) -> String {
        // 본문 sanitize 같은 토큰 제거 + 공백/줄바꿈/구두점 제거 + 길이 제한.
        var text = sanitize(raw)
        text = text.replacingOccurrences(of: "\n", with: " ")
        text = text.replacingOccurrences(of: ".", with: "")
        text = text.replacingOccurrences(of: ",", with: "")
        text = text.replacingOccurrences(of: "!", with: "")
        text = text.replacingOccurrences(of: "?", with: "")
        // 보호 길이: 16자 이내로 클램프.
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(16))
    }

    private static func gradeLabel(_ grade: Int, language: DescriptionLanguage) -> String {
        switch (grade, language) {
        case (0, .ko): return "늑대급"
        case (1, .ko): return "호랑이급"
        case (2, .ko): return "귀급"
        case (3, .ko): return "용급"
        case (4, .ko): return "신급"
        case (0, .ja): return "狼級"
        case (1, .ja): return "虎級"
        case (2, .ja): return "鬼級"
        case (3, .ja): return "竜級"
        case (4, .ja): return "神級"
        case (0, .en): return "Wolf class"
        case (1, .en): return "Tiger class"
        case (2, .en): return "Demon class"
        case (3, .en): return "Dragon class"
        case (4, .en): return "God class"
        default: return ""
        }
    }

    /// 영문 메타-지시 + 타깃 언어 명시 + 짧은 예시 — 비영어(특히 한국어) 응답에서
    /// 구조화 출력을 더 안정적으로 따르도록.
    private static func systemInstructions(language: DescriptionLanguage) -> String {
        let langName: String
        let exCodename: String
        let exDescription: String
        let descGuide: String
        switch language {
        case .ko:
            langName = "Korean"
            exCodename = "광기두꺼비"
            exDescription = "신호등을 점멸시키는 청개구리."
            descGuide = "ONE short Korean sentence, around 15-25 characters total"
        case .ja:
            langName = "Japanese"
            exCodename = "狂気ガエル"
            exDescription = "信号機を点滅させるカエル。"
            descGuide = "ONE short Japanese sentence, around 12-20 characters total"
        case .en:
            langName = "English"
            exCodename = "MadToad"
            exDescription = "A frog that flickers traffic lights."
            descGuide = "ONE short English sentence, around 30-50 characters total"
        }

        return """
        You are an archivist at the fictional 'Monster Association' (One-Punch Man universe). For a newly classified fictional monster character, output a codename and a very short description.

        OUTPUT LANGUAGE: \(langName) ONLY. Both fields must be written in \(langName).

        codename: a short single word or compound in \(langName). Avoid real personal names. No spaces, no punctuation.
        description: \(descGuide). Funny tone. Plain text only — no markdown, no quotes, no emoji, no numbers, no grade labels (wolf/tiger/demon/dragon/god class), no codename repetition. Keep it punchy and short.

        Example output (\(langName)):
        codename: \(exCodename)
        description: \(exDescription)
        """
    }

    /// userPrompt 도 영문으로 통일 — 메타 지시는 영어, 값은 타깃 언어로 들어옴.
    /// hints 는 이미 타깃 언어로 변환된 키워드라 그대로 전달.
    private static func userPrompt(_ input: Input) -> String {
        let grade = gradeLabel(input.grade, language: input.language)
        let hints = input.ratios.map { featureHints(for: $0, language: input.language) } ?? []
        let hintsLine = hints.isEmpty ? "" : "\nFeatures: \(hints.joined(separator: ", "))"
        return """
        Threat tier: \(grade)\(hintsLine)
        Generate the monster now.
        """
    }

    /// 비율 → 사람말 특징 키워드 (정상 범위에서 벗어난 항목만). 숫자/측정 표현을 LLM 에 노출하지 않아
    /// 안전 가드레일을 자극하지 않고도 외형 양념을 제공.
    private static func featureHints(for ratios: FaceMeasureSession.RatioSnapshot, language: DescriptionLanguage) -> [String] {
        var hints: [String] = []

        // 눈 간격 (target 1.1)
        if ratios.eyeRatio > 1.30 {
            hints.append(localized(.eyesWide, language))
        } else if ratios.eyeRatio < 0.90 {
            hints.append(localized(.eyesClose, language))
        }
        // 코 비율 (target 0.6)
        if ratios.noseRatio > 0.75 {
            hints.append(localized(.noseWide, language))
        } else if ratios.noseRatio < 0.45 {
            hints.append(localized(.noseNarrow, language))
        }
        // 입 비율 (target 2.6)
        if ratios.lipsRatio > 3.50 {
            hints.append(localized(.mouthWide, language))
        } else if ratios.lipsRatio < 1.80 {
            hints.append(localized(.mouthSmall, language))
        }
        // 얼굴 상하 비율 (target 1.1)
        if ratios.faceRatio > 1.40 {
            hints.append(localized(.foreheadLong, language))
        } else if ratios.faceRatio < 0.80 {
            hints.append(localized(.chinLong, language))
        }

        return hints
    }

    private enum FeatureKey {
        case eyesWide, eyesClose, noseWide, noseNarrow
        case mouthWide, mouthSmall, foreheadLong, chinLong
    }

    private static func localized(_ key: FeatureKey, _ language: DescriptionLanguage) -> String {
        switch (key, language) {
        case (.eyesWide, .ko): return "양눈이 멀리 떨어진"
        case (.eyesWide, .ja): return "両眼が離れた"
        case (.eyesWide, .en): return "wide-set eyes"

        case (.eyesClose, .ko): return "양눈이 모인"
        case (.eyesClose, .ja): return "両眼が寄った"
        case (.eyesClose, .en): return "close-set eyes"

        case (.noseWide, .ko): return "코가 옆으로 퍼진"
        case (.noseWide, .ja): return "鼻が横に広い"
        case (.noseWide, .en): return "wide flat nose"

        case (.noseNarrow, .ko): return "코가 길쭉한"
        case (.noseNarrow, .ja): return "鼻が細長い"
        case (.noseNarrow, .en): return "narrow long nose"

        case (.mouthWide, .ko): return "입이 옆으로 늘어진"
        case (.mouthWide, .ja): return "口が横に伸びた"
        case (.mouthWide, .en): return "wide stretched mouth"

        case (.mouthSmall, .ko): return "입이 작고 동그란"
        case (.mouthSmall, .ja): return "口が小さく丸い"
        case (.mouthSmall, .en): return "small round mouth"

        case (.foreheadLong, .ko): return "이마가 시원하게 넓은"
        case (.foreheadLong, .ja): return "おでこが広い"
        case (.foreheadLong, .en): return "tall forehead"

        case (.chinLong, .ko): return "턱이 길쭉한"
        case (.chinLong, .ja): return "顎が長い"
        case (.chinLong, .en): return "long chin"
        }
    }
}
