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

    /// 너무 길게 뱉을 때만 마지막 단어 경계에서 자름. 종결부호 컷팅은 빈 결과(한국어 첫 글자가 부호인 경우 등)
    /// 을 만들 수 있어 폐기. 프롬프트에 '한 문장만' 이 박혀 있어 보통은 한 문장.
    private static func clampDescription(_ raw: String, language: DescriptionLanguage) -> String {
        let limit: Int = (language == .en) ? 100 : 50
        let collapsed = raw
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        let head = String(collapsed.prefix(limit))
        if let lastSpace = head.lastIndex(of: " ") {
            return String(head[..<lastSpace]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
        }
        return head.trimmingCharacters(in: .whitespacesAndNewlines) + "…"
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

    private static func systemInstructions(language: DescriptionLanguage) -> String {
        switch language {
        case .ko:
            return """
            너는 원펀맨 세계관 가상의 '괴인 협회' 자료실 사서. 가상의 괴인 캐릭터 한 명에 대해:
            - codename: 한국어 합성어 한 단어 (예: 광기두꺼비, 입짧은신, 야근전사)
            - description: 한 문장으로 웃기게 (40자 이하, 평문)
            """
        case .ja:
            return """
            あなたはワンパンマン世界の架空『怪人協会』資料室司書。架空の怪人キャラ一体について:
            - codename: 日本語の合成語一語 (例: 狂気ガエル, 残業戦士)
            - description: 一文で面白く (40字以下、平文)
            """
        case .en:
            return """
            You are a fictional Monster Association bestiary archivist (One-Punch Man universe). For one fictional monster:
            - codename: one English compound word (e.g. AbyssEye, OvertimeWraith)
            - description: one funny sentence (under 90 chars, plain text)
            """
        }
    }

    private static func userPrompt(_ input: Input) -> String {
        let grade = gradeLabel(input.grade, language: input.language)
        let hints = input.ratios.map { featureHints(for: $0, language: input.language) } ?? []
        let hintsText = hints.joined(separator: ", ")

        switch input.language {
        case .ko:
            let featureLine = hints.isEmpty ? "" : " 특징: \(hintsText)."
            return "위협도: \(grade).\(featureLine) 이걸로 한 문장만 웃기게 만들어줘."
        case .ja:
            let featureLine = hints.isEmpty ? "" : " 特徴: \(hintsText)。"
            return "脅威度: \(grade)。\(featureLine)これで一文だけ面白く作って。"
        case .en:
            let featureLine = hints.isEmpty ? "" : " Traits: \(hintsText)."
            return "Threat: \(grade).\(featureLine) Write one funny sentence."
        }
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
