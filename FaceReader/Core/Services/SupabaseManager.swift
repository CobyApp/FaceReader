//
//  SupabaseManager.swift
//  FaceReader
//

import Foundation
import Supabase
import UIKit

final class SupabaseManager: @unchecked Sendable {
    static let shared = SupabaseManager()

    private let client: SupabaseClient
    private let monstersTable = "monsters"
    private let imageBucket = "monster-images"

    private init() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let publishableKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
            let supabaseURL = URL(string: urlString),
            !urlString.isEmpty,
            !publishableKey.isEmpty,
            !urlString.contains("$("),
            !publishableKey.contains("$(")
        else {
            fatalError(
                "Supabase is not configured. Copy .env.example to repo-root .env with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY, then build (FaceReaderEnv generates Secrets.generated.xcconfig). See supabase/README.md."
            )
        }

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: publishableKey)
    }

    // MARK: - Monsters

    func createMonster(nickname: String, image: UIImage, grade: Int, score: Int) async {
        let uid = UUID().uuidString
        let path = "\(uid).jpg"
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        do {
            try await client.storage
                .from(imageBucket)
                .upload(
                    path,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg", upsert: true)
                )

            let publicURL = try client.storage
                .from(imageBucket)
                .getPublicURL(path: path)

            let (year, month, day) = Date().dateToString
            let row = MonsterInsert(
                id: uid,
                nickname: nickname,
                image_url: publicURL.absoluteString,
                grade: grade,
                score: score,
                year: year,
                month: month,
                day: day
            )

            try await client
                .from(monstersTable)
                .insert(row)
                .execute()
        } catch {
            print("Failed to create monster: \(error)")
        }
    }

    func loadMonsters(term: Int, pages: Int) async -> (monsters: [Monster], lastDocumentID: String?)? {
        await fetchMonsters(term: term, offset: 0, pages: pages)
    }

    func continueMonsters(term: Int, lastDocumentID: String, pages: Int) async -> (monsters: [Monster], lastDocumentID: String?)? {
        guard let offset = Int(lastDocumentID) else { return nil }
        return await fetchMonsters(term: term, offset: offset, pages: pages)
    }

    private func fetchMonsters(term: Int, offset: Int, pages: Int) async -> (monsters: [Monster], lastDocumentID: String?)? {
        do {
            let (year, month, day) = Date().dateToString
            var builder = client.from(monstersTable).select()

            switch term {
            case 0:
                builder = builder.eq("year", value: year).eq("month", value: month).eq("day", value: day)
            case 1:
                builder = builder.eq("year", value: year).eq("month", value: month)
            case 2:
                builder = builder.eq("year", value: year)
            default:
                break
            }

            let upper = offset + pages - 1
            let rows: [MonsterRow] = try await builder
                .order("score", ascending: false)
                .range(from: offset, to: upper)
                .execute()
                .value

            let monsters = rows.map { $0.toMonster() }
            let nextOffset = offset + rows.count
            let lastID: String? = rows.count >= pages ? String(nextOffset) : nil
            return (monsters, lastID)
        } catch {
            print("error loading monsters: \(error)")
            return nil
        }
    }

    func deleteMonster(monster: Monster) async {
        do {
            if let path = storageObjectPath(from: monster.imageUrl) {
                try await client.storage.from(imageBucket).remove(paths: [path])
            }
            try await client
                .from(monstersTable)
                .delete()
                .eq("id", value: monster.uid)
                .execute()
        } catch {
            print("error deleting monster: \(error)")
        }
    }

    private func storageObjectPath(from publicURL: String) -> String? {
        guard let url = URL(string: publicURL) else { return nil }
        let marker = "/object/public/\(imageBucket)/"
        guard let range = url.path.range(of: marker) else { return nil }
        return String(url.path[range.upperBound...]).removingPercentEncoding
    }
}

// MARK: - DTOs

private struct MonsterRow: Decodable {
    let id: String
    let nickname: String
    let image_url: String
    let grade: Int
    let score: Int
    let year: String
    let month: String
    let day: String

    func toMonster() -> Monster {
        Monster(
            uid: id,
            nickname: nickname,
            imageUrl: image_url,
            grade: grade,
            score: score,
            year: year,
            month: month,
            day: day
        )
    }
}

private struct MonsterInsert: Encodable {
    let id: String
    let nickname: String
    let image_url: String
    let grade: Int
    let score: Int
    let year: String
    let month: String
    let day: String
}
