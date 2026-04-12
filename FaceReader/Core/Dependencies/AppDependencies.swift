//
//  AppDependencies.swift
//  FaceReader
//

import ComposableArchitecture
import Foundation

extension RankingClient: DependencyKey {
    static let liveValue = RankingClient(
        loadFirstPage: { term, pageSize in
            guard let page = await SupabaseManager.shared.loadMonsters(term: term, pages: pageSize) else {
                return .failure(.loadFailed)
            }
            return .success(RankingPage(monsters: page.monsters, lastDocumentID: page.lastDocumentID))
        },
        loadNextPage: { term, lastDocumentID, pageSize in
            guard let page = await SupabaseManager.shared.continueMonsters(term: term, lastDocumentID: lastDocumentID, pages: pageSize) else {
                return .failure(.loadFailed)
            }
            return .success(RankingPage(monsters: page.monsters, lastDocumentID: page.lastDocumentID))
        }
    )

    static let testValue = liveValue
}

extension MonsterMutationClient: DependencyKey {
    static let liveValue = MonsterMutationClient(
        createMonster: { nickname, image, grade, score in
            await SupabaseManager.shared.createMonster(nickname: nickname, image: image, grade: grade, score: score)
        },
        deleteMonster: { monster in
            await SupabaseManager.shared.deleteMonster(monster: monster)
        }
    )

    static let testValue = liveValue
}

private enum NicknamePreferencesKey: DependencyKey {
    static let liveValue = NicknamePreferences.userDefaults
    static let testValue = NicknamePreferences.userDefaults
}

extension DependencyValues {
    var rankingClient: RankingClient {
        get { self[RankingClient.self] }
        set { self[RankingClient.self] = newValue }
    }

    var monsterMutationClient: MonsterMutationClient {
        get { self[MonsterMutationClient.self] }
        set { self[MonsterMutationClient.self] = newValue }
    }

    var nicknamePreferences: NicknamePreferences {
        get { self[NicknamePreferencesKey.self] }
        set { self[NicknamePreferencesKey.self] = newValue }
    }
}
