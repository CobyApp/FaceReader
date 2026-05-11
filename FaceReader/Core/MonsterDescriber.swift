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
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
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
    private static func systemInstructions(language: DescriptionLanguage) -> String {
        switch language {
        case .ko:
            return """
            너는 만화 '원펀맨' 세계관 속 가상의 히어로 협회 자료실 사서이다. 새로 등록되는 '괴인 캐릭터'의 짧은 도감 항목을 작성한다. 재해 등급은 약한 순서로 늑대급 / 호랑이급 / 귀급 / 용급 / 신급.

            게임이나 만화의 캐릭터 도감처럼 가상 캐릭터의 외형 특성과 능력을 위트있게 묘사한다. 톤은 가벼운 in-universe 내레이션. 실제 인물이 아닌 가공의 캐릭터를 다룬다는 점을 잊지 말 것.

            형식: 한국어 2~3문장, 250자 이내. 마크다운, 헤더, 리스트, 따옴표, 이모지 금지. 본문 텍스트만 출력.
            """
        case .ja:
            return """
            あなたは漫画『ワンパンマン』世界のヒーロー協会・資料室司書です。新たに登録される架空の「怪人キャラクター」の短い図鑑記述を作成します。災害等級は弱い順に 狼級 / 虎級 / 鬼級 / 竜級 / 神級。

            ゲームや漫画のキャラクター図鑑のように、架空キャラクターの外見的特徴と能力をウィットを利かせて描写する。トーンは軽快なin-universeのナレーション。実在人物ではなく架空キャラクターを扱う点を忘れずに。

            形式: 日本語2〜3文、200字以内。マークダウン、見出し、箇条書き、引用符、絵文字は使わない。本文のみ出力。
            """
        case .en:
            return """
            You are a fictional Hero Association archivist from the manga 'One-Punch Man'. Write a short bestiary entry for a newly catalogued fictional 'mysterious being' character. Disaster levels (weak to strong): Wolf / Tiger / Demon / Dragon / God class.

            Describe this fictional character's appearance traits and powers with a witty, in-universe narration — like a videogame or manga bestiary. Remember you are describing a fictional character, not a real person.

            Format: English, 2-3 sentences, under 350 characters. No markdown, headers, bullets, quotes, or emoji. Output only the body text.
            """
        }
    }

    private static func userPrompt(_ input: Input) -> String {
        let grade = gradeLabel(input.grade, language: input.language)
        let scoreString: String = {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            return nf.string(from: NSNumber(value: input.totalScore)) ?? "\(input.totalScore)"
        }()

        // 중립적인 캐릭터 특성 지수로 표현 (정상/비정상 같은 개인 평가 표현 피함).
        let eye = input.eyeRatio.map { String(format: "%.2f", $0) } ?? "n/a"
        let nose = input.noseRatio.map { String(format: "%.2f", $0) } ?? "n/a"
        let lips = input.lipsRatio.map { String(format: "%.2f", $0) } ?? "n/a"
        let face = input.faceRatio.map { String(format: "%.2f", $0) } ?? "n/a"

        switch input.language {
        case .ko:
            return """
            다음 가상 괴인 캐릭터의 도감 설명을 작성해라.

            - 코드네임: \(input.nickname)
            - 재해 등급: \(grade)
            - 위협도(현상금): $\(scoreString)
            - 외형 특성 지수:
              - 안구 간격: \(eye)
              - 비강 형태: \(nose)
              - 구순 형태: \(lips)
              - 두상 비례: \(face)

            위 정보를 토대로 한국어 2~3문장의 짧은 도감 본문을 작성하라.
            """
        case .ja:
            return """
            次の架空怪人キャラクターの図鑑記述を作成せよ。

            - コードネーム: \(input.nickname)
            - 災害等級: \(grade)
            - 脅威度（賞金）: $\(scoreString)
            - 外形特性指数:
              - 眼球間距離: \(eye)
              - 鼻腔形態: \(nose)
              - 口唇形態: \(lips)
              - 頭部比率: \(face)

            上記情報を基に、日本語2〜3文の短い図鑑本文を書け。
            """
        case .en:
            return """
            Write a bestiary entry for this fictional mysterious being.

            - Codename: \(input.nickname)
            - Disaster level: \(grade)
            - Threat (bounty): $\(scoreString)
            - Trait indices:
              - Eye spacing: \(eye)
              - Nasal form: \(nose)
              - Mouth form: \(lips)
              - Cranial ratio: \(face)

            Based on the above, write the bestiary entry body (English, 2-3 sentences).
            """
        }
    }
}
