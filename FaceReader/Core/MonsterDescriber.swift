//
//  MonsterDescriber.swift
//  FaceReader
//

import Foundation
import FoundationModels

/// Apple Intelligence (Foundation Models) on-device 모델로 원펀맨 세계관의 가상 괴인 도감 설명을 생성.
public actor MonsterDescriber {
    public enum DescriptionLanguage: String, Sendable {
        case ko, ja, en
    }

    public enum DescribeError: Error, Sendable {
        case unavailable(reason: String)
        case guardrailBlocked
        case generationFailed(String)
    }

    public struct Input: Sendable {
        public let grade: Int           // 0=wolf ~ 4=god
        public let totalScore: Int
        public let eyeRatio: Double?
        public let noseRatio: Double?
        public let lipsRatio: Double?
        public let faceRatio: Double?
        public let nickname: String
        public let language: DescriptionLanguage

        public init(grade: Int, totalScore: Int, eyeRatio: Double?, noseRatio: Double?, lipsRatio: Double?, faceRatio: Double?, nickname: String, language: DescriptionLanguage) {
            self.grade = grade
            self.totalScore = totalScore
            self.eyeRatio = eyeRatio
            self.noseRatio = noseRatio
            self.lipsRatio = lipsRatio
            self.faceRatio = faceRatio
            self.nickname = nickname
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

    public func generate(_ input: Input) async throws -> String {
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
            let response = try await session.respond(to: prompt)
            return Self.sanitize(response.content)
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

    /// LLM 이 가끔 무시하는 마크다운 기호와 인용부호를 제거. 빈 줄 정리도.
    private static func sanitize(_ raw: String) -> String {
        var text = raw
        for token in ["**", "__", "~~", "```", "`"] {
            text = text.replacingOccurrences(of: token, with: "")
        }
        // 단일 * 또는 _ 가 문장에 박혀있으면 같이 제거 (의도 없는 강조 마커일 가능성).
        text = text.replacingOccurrences(of: "*", with: "")
        // 따옴표/홑따옴표 양 끝만 제거 (도감 인용형으로 감싸는 경우)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let openClose: [(Character, Character)] = [("\"", "\""), ("“", "”"), ("「", "」"), ("『", "』")]
        if let first = trimmed.first, let last = trimmed.last,
           openClose.contains(where: { $0.0 == first && $0.1 == last }) {
            return String(trimmed.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }

    // MARK: - Prompt building

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

    /// 안전 가드레일을 피하기 위해 '실제 사람 외모 평가'가 아니라 '가상 캐릭터 도감 작성'으로 프레이밍.
    /// 출력에 숫자/측정값 절대 노출 금지 + 마크다운 기호 금지를 명시.
    private static func systemInstructions(language: DescriptionLanguage) -> String {
        switch language {
        case .ko:
            return """
            너는 만화 '원펀맨' 세계관 속 가상의 히어로 협회 자료실 사서야. 새로 등록된 가상의 '괴인 캐릭터'에 대해 짧고 재밌는 도감 한 줄을 쓴다. 재해 등급은 약한 순서로 늑대급 / 호랑이급 / 귀급 / 용급 / 신급.

            톤: 만화 도감 같은 가벼운 in-universe 내레이션, 짧고 위트있게. 실제 사람이 아닌 가공의 캐릭터를 다룬다.

            금지: 숫자, 점수, 측정값, 비율, 지수, 통계, 데이터, 단위(달러 $, %) — 어떤 정량 표현도 본문에 등장시키지 마라. 캐릭터의 분위기·특성·능력 위주로만 풀어쓴다. 마크다운(**, *, _, __, ~, `, #, -, > 등), 따옴표, 이모지, 줄바꿈, 리스트, 헤더 일체 금지.

            형식: 한국어 평문 1~2문장, 120자 이내. 본문만 출력.
            """
        case .ja:
            return """
            あなたは漫画『ワンパンマン』世界のヒーロー協会・資料室司書。新たに登録された架空の「怪人キャラクター」について、短くて面白い図鑑コメントを一行書く。災害等級は弱い順に 狼級 / 虎級 / 鬼級 / 竜級 / 神級。

            トーン: マンガ図鑑のような軽快なin-universeナレーション、短く小粋に。実在人物ではなく架空キャラクターを扱う。

            禁止: 数字、点数、測定値、比率、指数、統計、データ、単位(ドル$、%) など、いかなる定量表現も本文に出さない。キャラクターの雰囲気・特性・能力のみで書く。マークダウン(**, *, _, __, ~, `, #, -, > 等)、引用符、絵文字、改行、リスト、見出し一切禁止。

            形式: 日本語平文1〜2文、100字以内。本文のみ出力。
            """
        case .en:
            return """
            You are a fictional Hero Association archivist from the manga 'One-Punch Man'. Write one short, witty bestiary line for a newly catalogued fictional 'mysterious being' character. Disaster levels (weak to strong): Wolf / Tiger / Demon / Dragon / God class.

            Tone: light in-universe narration like a manga bestiary, short and punchy. Remember you describe a fictional character, not a real person.

            Forbidden: numbers, scores, measurements, ratios, indices, statistics, data, units (dollar $, %) — no quantitative expression of any kind in the body. Describe only the character's vibe, traits, and powers. No markdown (**, *, _, __, ~, `, #, -, > etc.), no quotes, no emoji, no line breaks, no lists, no headers.

            Format: plain English, 1-2 sentences, under 200 characters. Output body text only.
            """
        }
    }

    private static func userPrompt(_ input: Input) -> String {
        let grade = gradeLabel(input.grade, language: input.language)
        // 수치/점수/비율 + 닉네임 일체 미전달 — 닉네임은 포스터에 따로 있어 본문에서 다시 언급 불필요.
        switch input.language {
        case .ko:
            return "재해 등급 \(grade) 인 가상 괴인 캐릭터의 도감 한 줄을 한국어로 짧고 재밌게 써라. 이름은 언급하지 마라. 캐릭터의 외형·분위기·능력 위주로만."
        case .ja:
            return "災害等級 \(grade) の架空怪人キャラクターの図鑑コメント一行を日本語で短く面白く書け。名前は出さない。外見・雰囲気・能力のみで。"
        case .en:
            return "Write one short, witty bestiary line in English for a fictional Disaster level \(grade) mysterious being. Do not mention any name. Focus on appearance, vibe, and powers only."
        }
    }
}
