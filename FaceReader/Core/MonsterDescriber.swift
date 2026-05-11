//
//  MonsterDescriber.swift
//  FaceReader
//

import Foundation
import FoundationModels

/// Apple Intelligence (Foundation Models) on-device 모델로 원펀맨 세계관의 헛소리 보고서를 생성.
public actor MonsterDescriber {
    public enum DescriptionLanguage: String, Sendable {
        case ko, ja, en
    }

    public enum DescribeError: Error, Sendable {
        case unavailable(reason: String)
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

    /// 모델 가용성 + 사용자 Apple Intelligence 활성화 여부.
    public static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        default: return false
        }
    }

    /// 모델 사용 불가시 사람 친화 사유 메시지. 사용 가능하면 nil.
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

    /// 입력값으로 짧은 (1~3문장) 원펀맨 풍자 보고서 생성.
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

    private static func systemInstructions(language: DescriptionLanguage) -> String {
        switch language {
        case .ko:
            return """
            너는 만화 '원펀맨' 세계관의 히어로 협회 분석관이다. 새로 발견된 '괴인'을 분류하고 짧은 보고서를 작성한다. 재해 등급은 낮은 순서로 늑대급 / 호랑이급 / 귀급 / 용급 / 신급이다.

            톤은 시니컬하면서도 한국어 인터넷 유머 감각으로 살짝 유치하게. 등급, 위협도, 얼굴 비율의 비정상성을 가지고 농담을 친다. 절대 사용자(괴인 본인)를 모욕하지 말고, 어디까지나 가공의 '괴인 캐릭터'를 평가하는 식으로 쓴다. 한국어로만 작성한다.

            형식: 2~3문장. 250자 이내. 마크다운, 헤더, 리스트, 따옴표, 이모지 사용 금지. 보고서 본문만 출력한다.
            """
        case .ja:
            return """
            あなたは漫画『ワンパンマン』世界のヒーロー協会・分析官です。新たに発見された「怪人」を分類し、短い報告書を作成します。災害等級は弱い順に 狼級 / 虎級 / 鬼級 / 竜級 / 神級 です。

            トーンはシニカルでありながら、日本のネットスラング寄りの軽妙さで。等級、脅威度、顔のバランスの異常さを材料にユーモアを効かせる。決してユーザー本人を侮辱せず、あくまで架空の「怪人キャラクター」を評価する体裁で書く。日本語のみで書く。

            形式: 2〜3文。200字以内。マークダウン、見出し、箇条書き、引用符、絵文字は使わない。本文のみ出力。
            """
        case .en:
            return """
            You are a Hero Association analyst from the manga 'One-Punch Man'. Classify a newly discovered 'mysterious being' (怪人) and write a brief field report. Disaster levels from weakest to strongest: Wolf class / Tiger class / Demon class / Dragon class / God class.

            Tone: dry, in-universe, with a streak of absurd humor. Riff on the threat level, the bounty, and the asymmetry of the subject's facial ratios. Never insult the actual user — keep it in character about the fictional 'monster'. Write in English only.

            Format: 2-3 sentences, under 350 characters. No markdown, headers, bullets, quotes, or emoji. Output only the body text.
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

        // 비율들 → 정상값과 얼마나 어긋났는지를 percentile 식으로 풀어 전달
        let eyeDelta = input.eyeRatio.map { String(format: "%.2f", abs($0 - 1.1)) } ?? "n/a"
        let noseDelta = input.noseRatio.map { String(format: "%.2f", abs($0 - 0.6)) } ?? "n/a"
        let lipsDelta = input.lipsRatio.map { String(format: "%.2f", abs($0 - 2.6)) } ?? "n/a"
        let faceDelta = input.faceRatio.map { String(format: "%.2f", abs($0 - 1.1)) } ?? "n/a"

        switch input.language {
        case .ko:
            return """
            새로 식별된 괴인을 평가해라.

            - 이름: \(input.nickname)
            - 재해 등급: \(grade)
            - 위협도(현상금): $\(scoreString)
            - 정상 비율 대비 일탈치 (클수록 비정상):
              - 눈 사이 간격: \(eyeDelta)
              - 코 비율: \(noseDelta)
              - 입술 비율: \(lipsDelta)
              - 상하 얼굴 비율: \(faceDelta)

            위 정보를 토대로 한국어 2~3문장의 짧은 보고서를 본문만 작성해라.
            """
        case .ja:
            return """
            新たに識別された怪人を評価せよ。

            - 名前: \(input.nickname)
            - 災害等級: \(grade)
            - 脅威度（賞金）: $\(scoreString)
            - 標準比率からの乖離 (大きいほど異常):
              - 両眼の間隔: \(eyeDelta)
              - 鼻の比率: \(noseDelta)
              - 唇の比率: \(lipsDelta)
              - 顔の上下比率: \(faceDelta)

            上記情報を基に、日本語2〜3文の短い報告書を本文のみ書け。
            """
        case .en:
            return """
            Classify this newly identified mysterious being.

            - Designation: \(input.nickname)
            - Disaster level: \(grade)
            - Threat (bounty): $\(scoreString)
            - Deviation from baseline ratios (higher = more abnormal):
              - Inter-eye spacing: \(eyeDelta)
              - Nose ratio: \(noseDelta)
              - Lip ratio: \(lipsDelta)
              - Upper/lower face ratio: \(faceDelta)

            Based on the above, write the report body (English, 2-3 sentences) only.
            """
        }
    }
}
