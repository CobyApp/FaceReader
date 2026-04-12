//
//  RankingClient.swift
//  FaceReader
//

import Foundation

struct RankingPage: Equatable, Sendable {
    var monsters: [Monster]
    var lastDocumentID: String?
}

enum RankingClientError: Error, Equatable, Sendable {
    case loadFailed
}

struct RankingClient: Sendable {
    var loadFirstPage: @Sendable (_ term: Int, _ pageSize: Int) async -> Result<RankingPage, RankingClientError>
    var loadNextPage: @Sendable (_ term: Int, _ lastDocumentID: String, _ pageSize: Int) async -> Result<RankingPage, RankingClientError>
}
