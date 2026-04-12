//
//  RankingView.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderLocalization
import SwiftUI

struct RankingView: View {
    @Bindable var store: StoreOf<RankingFeature>
    var onMonsterTap: (Monster) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: Binding(
                get: { store.term },
                set: { store.send(.termChanged($0)) }
            )) {
                ForEach(0 ..< L10n.rankingTerms.count, id: \.self) { index in
                    Text(L10n.rankingTerms[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                if store.monsters.isEmpty, !store.isRefreshing {
                    Text(L10n.emptyRankList)
                        .font(.app(17))
                        .foregroundStyle(Color.appText.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }

                ForEach(store.monsters) { monster in
                    MonsterRowView(monster: monster)
                        .contentShape(Rectangle())
                        .onTapGesture { onMonsterTap(monster) }
                        .onAppear {
                            if monster.id == store.monsters.last?.id {
                                store.send(.reachedBottom)
                            }
                        }
                }

                if store.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            }
        }
        .refreshable { await refresh() }
        .onAppear { store.send(.onAppear) }
    }

    private func refresh() async {
        store.send(.refresh)
        for _ in 0 ..< 200 where !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 50_000_000)
            if !store.isRefreshing { break }
        }
    }
}

private struct MonsterRowView: View {
    let monster: Monster

    var body: some View {
        HStack(spacing: 12) {
            Image(GradeAssets.imageName(for: monster.grade))
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(monster.nickname)
                    .font(.app(18))
                    .foregroundStyle(Color.appText)
                Text(L10n.formattedScore(monster.score))
                    .font(.app(15))
                    .foregroundStyle(Color.appText.opacity(0.7))
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.appText.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
