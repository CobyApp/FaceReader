//
//  FaceResultFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderCore
import FaceReaderLocalization
import Foundation

@Reducer
public struct FaceResultFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var box: SessionBox
        public var nicknameLine: String = ""
        /// Snapshot used for the wanted poster (TCA-visible so the result screen always redraws).
        public var posterImageData: Data?

        public enum DescriptionStatus: Equatable {
            case idle
            case loading
            case loaded(String)
            case failed(String)
        }

        public var descriptionStatus: DescriptionStatus = .idle

        public init(box: SessionBox, posterImageData: Data? = nil) {
            self.box = box
            self.posterImageData = posterImageData
        }
    }

    public enum Action: Equatable {
        case onAppear
        case dismissTapped
        case requestDescription(nickname: String)
        case descriptionLoaded(Result<String, FailureMessage>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismiss
        }
    }

    public struct FailureMessage: Equatable, Error {
        public let message: String
        public init(_ message: String) { self.message = message }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.nicknameLine = L10n.anonymousMonster
                return .none

            case let .requestDescription(nickname):
                // Apple Intelligence 가용성 사유를 사용자에게 그대로 노출 (idle 로 숨겨버리면 안 보여 디버깅 불가).
                if let unavailableReason = MonsterDescriber.unavailableReason {
                    state.descriptionStatus = .failed(unavailableReason)
                    return .none
                }
                state.descriptionStatus = .loading
                let session = state.box.session
                let grade = session.grade
                let score = session.totalScore
                let ratios = session.lastRatios
                let language: MonsterDescriber.DescriptionLanguage = {
                    switch LanguageResolver.effectiveResourceTag() {
                    case "ko": return .ko
                    case "ja": return .ja
                    default: return .en
                    }
                }()
                return .run { send in
                    let describer = MonsterDescriber()
                    let input = MonsterDescriber.Input(
                        grade: grade,
                        totalScore: score,
                        eyeRatio: ratios?.eyeRatio,
                        noseRatio: ratios?.noseRatio,
                        lipsRatio: ratios?.lipsRatio,
                        faceRatio: ratios?.faceRatio,
                        nickname: nickname,
                        language: language
                    )
                    do {
                        let text = try await describer.generate(input)
                        await send(.descriptionLoaded(.success(text)))
                    } catch {
                        await send(.descriptionLoaded(.failure(FailureMessage(String(describing: error)))))
                    }
                }

            case let .descriptionLoaded(.success(text)):
                state.descriptionStatus = .loaded(text)
                return .none

            case let .descriptionLoaded(.failure(failure)):
                state.descriptionStatus = .failed(failure.message)
                return .none

            case .dismissTapped:
                return .send(.delegate(.dismiss))

            case .delegate:
                return .none
            }
        }
    }
}
