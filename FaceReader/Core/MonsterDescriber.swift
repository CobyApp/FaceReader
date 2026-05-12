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
        @Guide(description: "Villain codename. 2-10 characters, single word or compound, no spaces or punctuation. Match the requested language.")
        public var codename: String

        @Guide(description: "One funny sentence about the monster. Max 40 characters. Plain text, no quotes, no numbers, no codename.")
        public var description: String
    }

    public struct Input: Sendable {
        public let grade: Int
        public let language: DescriptionLanguage

        public init(grade: Int, language: DescriptionLanguage) {
            self.grade = grade
            self.language = language
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

    /// 한 문장 길이로 강제 자름. ko/ja 40자, en 90자.
    private static func clampDescription(_ raw: String, language: DescriptionLanguage) -> String {
        let limit: Int = (language == .en) ? 90 : 40
        let collapsed = raw
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 첫 종결부호까지만 — 한 문장만 살림.
        let terminators: Set<Character> = [".", "!", "?", "。", "！", "？"]
        if let firstEnd = collapsed.firstIndex(where: { terminators.contains($0) }) {
            let firstSentence = String(collapsed[...firstEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
            return enforceLimit(firstSentence, limit: limit)
        }
        return enforceLimit(collapsed, limit: limit)
    }

    private static func enforceLimit(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        let head = String(text.prefix(limit))
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
            너는 원펀맨 세계관의 가상 괴인 도감 사서. 가상의 괴인 캐릭터 한 명에 대해:
            - codename: 한국어 합성어 한 단어 (예: 광기두꺼비, 입짧은신, 야근전사)
            - description: 한 문장으로 웃기게 (40자 이하, 평문)
            """
        case .ja:
            return """
            あなたはワンパンマン世界の架空怪人図鑑司書。架空の怪人キャラ一体について:
            - codename: 日本語の合成語一語 (例: 狂気ガエル, 残業戦士)
            - description: 一文で面白く (40字以下、平文)
            """
        case .en:
            return """
            You are a fictional One-Punch Man bestiary archivist. For one fictional monster:
            - codename: one English compound word (e.g. AbyssEye, OvertimeWraith)
            - description: one funny sentence (under 90 chars, plain text)
            """
        }
    }

    private static func userPrompt(_ input: Input) -> String {
        let grade = gradeLabel(input.grade, language: input.language)
        switch input.language {
        case .ko:
            return "위협도: \(grade). 어울리는 가상 괴인 만들어줘."
        case .ja:
            return "脅威度: \(grade)。それっぽい架空怪人を作って。"
        case .en:
            return "Threat: \(grade). Make a matching fictional monster."
        }
    }
}
