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
        /// Snapshot used for the wanted poster (TCA-visible so the result screen always redraws).
        public var posterImageData: Data?

        public enum ReportStatus: Equatable {
            case idle
            case loading
            case loaded(codename: String, description: String)
            case failed(String)
        }

        public var reportStatus: ReportStatus = .idle

        public init(box: SessionBox, posterImageData: Data? = nil) {
            self.box = box
            self.posterImageData = posterImageData
        }
    }

    public enum Action: Equatable {
        case onAppear
        case dismissTapped
        case requestReport
        case reportLoaded(Result<ReportPayload, FailureMessage>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismiss
        }
    }

    public struct ReportPayload: Equatable, Sendable {
        public let codename: String
        public let description: String
    }

    public struct FailureMessage: Equatable, Error {
        public let message: String
        public init(_ message: String) { self.message = message }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .requestReport:
                if let unavailableReason = MonsterDescriber.unavailableReason {
                    state.reportStatus = .failed(unavailableReason)
                    return .none
                }
                state.reportStatus = .loading
                let grade = state.box.session.grade
                let language: MonsterDescriber.DescriptionLanguage = {
                    switch LanguageResolver.effectiveResourceTag() {
                    case "ko": return .ko
                    case "ja": return .ja
                    default: return .en
                    }
                }()
                return .run { send in
                    let describer = MonsterDescriber()
                    let input = MonsterDescriber.Input(grade: grade, language: language)
                    do {
                        let report = try await describer.generate(input)
                        await send(.reportLoaded(.success(ReportPayload(codename: report.codename, description: report.description))))
                    } catch MonsterDescriber.DescribeError.guardrailBlocked {
                        await send(.reportLoaded(.failure(FailureMessage("분석관이 평가를 거부했어요. (안전 가드레일)"))))
                    } catch MonsterDescriber.DescribeError.unavailable(let reason) {
                        await send(.reportLoaded(.failure(FailureMessage(reason))))
                    } catch MonsterDescriber.DescribeError.generationFailed(let reason) {
                        await send(.reportLoaded(.failure(FailureMessage("분석 중 오류: \(reason)"))))
                    } catch {
                        await send(.reportLoaded(.failure(FailureMessage(String(describing: error)))))
                    }
                }

            case let .reportLoaded(.success(payload)):
                state.reportStatus = .loaded(codename: payload.codename, description: payload.description)
                return .none

            case let .reportLoaded(.failure(failure)):
                state.reportStatus = .failed(failure.message)
                return .none

            case .dismissTapped:
                return .send(.delegate(.dismiss))

            case .delegate:
                return .none
            }
        }
    }
}
