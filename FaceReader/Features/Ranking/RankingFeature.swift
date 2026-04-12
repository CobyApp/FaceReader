//
//  RankingFeature.swift
//  FaceReader
//

import ComposableArchitecture
import Foundation

@Reducer
struct RankingFeature {
    static let pageSize = 50

    @ObservableState
    struct State: Equatable {
        var term = 0
        var monsters: [Monster] = []
        var lastDocumentID: String?
        var canLoadMore = true
        var isRefreshing = false
        var isLoadingMore = false
    }

    enum Action: Equatable {
        case onAppear
        case refresh
        case termChanged(Int)
        case reachedBottom
        case firstPageResponse(Result<RankingPage, RankingClientError>)
        case nextPageResponse(Result<RankingPage, RankingClientError>)
    }

    @Dependency(\.rankingClient) private var rankingClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return !state.monsters.isEmpty ? .none : .send(.refresh)

            case .refresh:
                guard !state.isRefreshing else { return .none }
                state.isRefreshing = true
                state.lastDocumentID = nil
                state.canLoadMore = true
                let term = state.term
                return .run { send in
                    let result = await rankingClient.loadFirstPage(term, Self.pageSize)
                    await send(.firstPageResponse(result))
                }

            case let .termChanged(index):
                state.term = index
                state.isRefreshing = false
                state.isLoadingMore = false
                state.canLoadMore = true
                state.monsters = []
                return .send(.refresh)

            case .reachedBottom:
                guard state.canLoadMore, !state.isRefreshing, !state.isLoadingMore, let lastID = state.lastDocumentID else {
                    return .none
                }
                state.isLoadingMore = true
                state.canLoadMore = false
                let term = state.term
                return .run { send in
                    let result = await rankingClient.loadNextPage(term, lastID, Self.pageSize)
                    await send(.nextPageResponse(result))
                }

            case let .firstPageResponse(result):
                switch result {
                case let .success(page):
                    state.isRefreshing = false
                    state.monsters = page.monsters
                    state.lastDocumentID = page.lastDocumentID
                    state.canLoadMore = page.monsters.count >= Self.pageSize && page.lastDocumentID != nil
                case .failure:
                    state.isRefreshing = false
                }
                return .none

            case let .nextPageResponse(result):
                switch result {
                case let .success(page):
                    state.isLoadingMore = false
                    state.monsters.append(contentsOf: page.monsters)
                    state.lastDocumentID = page.lastDocumentID
                    state.canLoadMore = page.monsters.count >= Self.pageSize && page.lastDocumentID != nil
                case .failure:
                    state.isLoadingMore = false
                    state.canLoadMore = state.lastDocumentID != nil
                }
                return .none
            }
        }
    }
}
