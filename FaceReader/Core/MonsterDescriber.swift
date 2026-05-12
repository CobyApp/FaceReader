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
        @Guide(description: "Short fictional villain codename. 2 to 12 characters. One word or compound. No real personal names. Match the requested language. Examples: 광기두꺼비, 심연안구, 狂気ガエル, AbyssEye.")
        public var codename: String

        @Guide(description: "Punchy bestiary blurb for a fictional being. About 2-3 short sentences, totaling roughly 60-90 characters. Plain text. Funny, manga-bestiary tone. Do not repeat the codename. Do not include grade labels, names, numbers, units, or markdown. Match the requested language.")
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
                description: Self.sanitize(raw.description)
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
            너는 만화 '원펀맨' 세계관 속 가상의 히어로 협회 자료실 사서다. 새로 등록된 가상의 '괴인 캐릭터'의 코드네임(별명)과 짧은 도감 본문을 동시에 만든다. 재해 등급: 늑대급 / 호랑이급 / 귀급 / 용급 / 신급.

            톤: 한국 인터넷 유머 + 만화 도감 패러디. 박장대소 가능한 어이없음/시니컬/과장. 실명이 아닌 가공 캐릭터. 절대 진지하게 쓰지 마라.

            codename(별명): 한국어 2~12자 단일 토큰(공백/구두점/줄바꿈 없음). 분위기 + 특이점 살린 합성어. 예시: 광기두꺼비, 절망꼬마, 멸망연골, 입짧은신, 야근전사, 우울메기.
            description(도감 본문): 2~3 짧은 문장, 총 60~90자. 한국어 평문. 코드네임, 등급 라벨(늑대급/호랑이급 등), 숫자, 측정값, 단위, 마크다운, 이모지, 따옴표 일체 금지. 캐릭터의 외형/분위기/능력으로만 풀어 쓰되 웃겨야 한다.
            """
        case .ja:
            return """
            あなたは漫画『ワンパンマン』世界のヒーロー協会・資料室司書。新たに登録された架空「怪人キャラクター」のコードネーム(別名)と短い図鑑本文を同時に作る。災害等級: 狼級 / 虎級 / 鬼級 / 竜級 / 神級。

            トーン: 日本のネットスラング寄りのおふざけ+マンガ図鑑パロディ。爆笑できる呆れ/シニカル/誇張。実在人物ではなく架空キャラ。決して真面目に書くな。

            codename(別名): 日本語2〜12文字の単一トークン(空白/句読点/改行なし)。雰囲気と特異点を活かした合成語。例: 狂気ガエル, 絶望チビ, 滅亡軟骨, 残業戦士, 鬱ナマズ。
            description(図鑑本文): 2〜3 短文、合計60〜90字。日本語平文。コードネーム、等級ラベル(狼級/虎級など)、数字、測定値、単位、マークダウン、絵文字、引用符は一切出力禁止。キャラの外見/雰囲気/能力のみで、必ず笑えるよう書け。
            """
        case .en:
            return """
            You are a fictional Hero Association archivist from the manga 'One-Punch Man'. Generate a codename and a short bestiary blurb for a newly catalogued fictional 'mysterious being'. Disaster levels: Wolf / Tiger / Demon / Dragon / God class.

            Tone: dry comedic, manga bestiary parody, absurd and snarky. The subject is a fictional character, not a real person. Never play it straight — be funny.

            codename: English 2-12 chars, single token (no spaces, punctuation, line breaks). Evocative compound handle. Examples: AbyssEye, DespairTot, RuinCartilage, OvertimeWraith, SadCatfish.
            description: 2-3 short sentences, 60-90 characters total. Plain English. Do NOT output the codename, any grade label (Wolf/Tiger/Demon/Dragon/God class), numbers, measurements, units, markdown, emoji, quotes. Describe only by appearance, atmosphere, and powers — make it funny.
            """
        }
    }

    private static func userPrompt(_ input: Input) -> String {
        let grade = gradeLabel(input.grade, language: input.language)
        switch input.language {
        case .ko:
            return """
            내부 참고용 재해 등급: \(grade) (이 라벨은 description 본문에 절대 쓰지 마라).

            이 등급의 위협 분위기를 살린 가상 괴인 캐릭터의 codename(별명)과 짧은 도감 description 을 생성하라.
            """
        case .ja:
            return """
            内部参考用の災害等級: \(grade)（このラベルはdescription本文に絶対書くな）。

            この等級の脅威の雰囲気を反映した架空怪人キャラクターのcodename(別名)と短い図鑑descriptionを生成せよ。
            """
        case .en:
            return """
            Internal reference disaster level: \(grade) (do NOT use this label in description body).

            Generate a codename and a short bestiary description for a fictional mysterious being whose vibe matches that threat level.
            """
        }
    }
}
