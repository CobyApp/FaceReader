//
//  AppFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderCore
import FaceReaderLocalization
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var sessionBox = SessionBox()
        /// 캡처 직후 LLM 평가 중 상태. 결과가 나오면 faceResult 로 승격.
        var pendingReport: PendingReport?
        var faceResult: FaceResultFeature.State?
        var isShowingHelp = false
        var settingsPresented = false
        var languageRefreshToken = 0
    }

    struct PendingReport: Equatable {
        let box: SessionBox
        let posterImageData: Data?
    }

    struct ReportFailure: Equatable, Error {
        let message: String
    }

    /// LLM 호출과 타임아웃의 race 결과. 첫 결과가 곧 운명.
    private enum LLMRaceResult: Sendable {
        case success(MonsterDescriber.MonsterReport)
        case failure
    }

    private static func activeLanguage() -> MonsterDescriber.DescriptionLanguage {
        switch LanguageResolver.effectiveResourceTag() {
        case "ko": return .ko
        case "ja": return .ja
        default: return .en
        }
    }

    private static func fallbackPayload(grade: Int, language: MonsterDescriber.DescriptionLanguage) -> FaceResultFeature.ReportPayload {
        let entry = FallbackMonsterLibrary.pick(grade: grade, language: language)
        return FaceResultFeature.ReportPayload(codename: entry.codename, description: entry.description)
    }

    enum Action: Equatable {
        case faceCaptureCommitted(posterImageData: Data?)
        case reportReady(Result<FaceResultFeature.ReportPayload, ReportFailure>)
        case faceResult(FaceResultFeature.Action)
        case helpButtonTapped
        case helpFinished
        case settingsButtonTapped
        case settingsDismissed
        case languagePreferenceSaved(String?)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .faceCaptureCommitted(data):
                let grade = state.sessionBox.session.grade
                let ratios = state.sessionBox.session.lastRatios
                let language = Self.activeLanguage()

                // Apple Intelligence 미지원/비활성: 로딩 없이 폴백 라이브러리로 즉시 결과 진입.
                if MonsterDescriber.unavailableReason != nil {
                    let payload = Self.fallbackPayload(grade: grade, language: language)
                    state.faceResult = FaceResultFeature.State(
                        box: state.sessionBox,
                        posterImageData: data,
                        report: payload
                    )
                    state.sessionBox = SessionBox()
                    return .none
                }
                state.pendingReport = PendingReport(box: state.sessionBox, posterImageData: data)
                return .run { send in
                    let describer = MonsterDescriber()
                    let input = MonsterDescriber.Input(grade: grade, language: language, ratios: ratios)

                    // LLM 호출 vs 5초 타임아웃 race — 늦거나 실패하면 폴백 경로.
                    let raceResult: LLMRaceResult = await withTaskGroup(of: LLMRaceResult.self) { group in
                        group.addTask {
                            do {
                                let report = try await describer.generate(input)
                                return .success(report)
                            } catch {
                                return .failure
                            }
                        }
                        group.addTask {
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                            return .failure
                        }
                        let first = await group.next() ?? .failure
                        group.cancelAll()
                        return first
                    }

                    switch raceResult {
                    case .success(let report):
                        let safeCodename = report.codename.trimmingCharacters(in: .whitespacesAndNewlines)
                        let safeDescription = report.description.trimmingCharacters(in: .whitespacesAndNewlines)
                        if safeCodename.isEmpty || safeDescription.isEmpty {
                            let fb = Self.fallbackPayload(grade: grade, language: language)
                            let merged = FaceResultFeature.ReportPayload(
                                codename: safeCodename.isEmpty ? fb.codename : safeCodename,
                                description: safeDescription.isEmpty ? fb.description : safeDescription
                            )
                            await send(.reportReady(.success(merged)))
                        } else {
                            await send(.reportReady(.success(FaceResultFeature.ReportPayload(
                                codename: safeCodename,
                                description: safeDescription
                            ))))
                        }
                    case .failure:
                        await send(.reportReady(.failure(ReportFailure(message: "llm-timeout-or-error"))))
                    }
                }

            case let .reportReady(.success(payload)):
                guard let pending = state.pendingReport else { return .none }
                state.pendingReport = nil
                state.faceResult = FaceResultFeature.State(
                    box: pending.box,
                    posterImageData: pending.posterImageData,
                    report: payload
                )
                state.sessionBox = SessionBox()
                return .none

            case .reportReady(.failure):
                guard let pending = state.pendingReport else { return .none }
                state.pendingReport = nil
                let grade = pending.box.session.grade
                let language = Self.activeLanguage()
                let payload = Self.fallbackPayload(grade: grade, language: language)
                state.faceResult = FaceResultFeature.State(
                    box: pending.box,
                    posterImageData: pending.posterImageData,
                    report: payload
                )
                state.sessionBox = SessionBox()
                return .none

            case .helpButtonTapped:
                state.isShowingHelp = true
                return .none

            case .helpFinished:
                state.isShowingHelp = false
                return .none

            case .faceResult(.delegate(.dismiss)):
                state.faceResult = nil
                state.sessionBox = SessionBox()
                return .none

            case .faceResult:
                return .none

            case .settingsButtonTapped:
                state.settingsPresented = true
                return .none

            case .settingsDismissed:
                state.settingsPresented = false
                return .none

            case let .languagePreferenceSaved(code):
                LanguageResolver.saveOverrideTag(code)
                state.languageRefreshToken += 1
                state.settingsPresented = false
                return .none
            }
        }
        .ifLet(\.faceResult, action: \.faceResult) {
            FaceResultFeature()
        }
    }
}
