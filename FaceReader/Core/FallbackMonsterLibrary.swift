//
//  FallbackMonsterLibrary.swift
//  FaceReader
//

import Foundation

/// LLM(Apple Intelligence) 미지원 / 호출 실패 / 빈 응답 / 5초 타임아웃 시 사용.
/// 언어별 100개(등급 5단계 × 20개) 풀에서 랜덤 선택.
/// 데이터는 메인 번들의 `fallback_monsters_<lang>.json` 에서 로드한다.
/// 형식 = LLM 출력과 동일: codename (단일 토큰) + description (2 짧은 문장).
public enum FallbackMonsterLibrary {
    public struct Entry: Sendable, Equatable, Decodable {
        public let codename: String
        public let description: String
    }

    public static func pick(grade: Int, language: MonsterDescriber.DescriptionLanguage) -> Entry {
        let clamped = max(0, min(4, grade))
        let table = library[language] ?? [:]
        let pool = table[clamped] ?? []
        guard let raw = pool.randomElement() else { return Entry(codename: "???", description: "") }
        return Entry(
            codename: raw.codename,
            description: MonsterDescriber.clampDescription(raw.description, language: language)
        )
    }

    private static let library: [MonsterDescriber.DescriptionLanguage: [Int: [Entry]]] = {
        var out: [MonsterDescriber.DescriptionLanguage: [Int: [Entry]]] = [:]
        for lang in [MonsterDescriber.DescriptionLanguage.ko, .ja, .en] {
            out[lang] = loadTable(language: lang)
        }
        return out
    }()

    private static func loadTable(language: MonsterDescriber.DescriptionLanguage) -> [Int: [Entry]] {
        let bundle = Bundle.main
        let baseName = "fallback_monsters_\(language.rawValue)"
        guard let url = bundle.url(forResource: baseName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [Entry]].self, from: data) else {
            return [:]
        }
        var table: [Int: [Entry]] = [:]
        for (key, entries) in decoded {
            if let g = Int(key) { table[g] = entries }
        }
        return table
    }
}
