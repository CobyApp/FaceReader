//
//  AppFeature.swift
//  FaceReader
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var ranking = RankingFeature.State()
        @Presents var nicknameSheet: NicknameFeature.State?
        @Presents var helpSheet: HelpFeature.State?
        @Presents var monsterPaper: MonsterPaperFeature.State?
        var faceCapture: SessionBox?
        var faceResult: FaceResultFeature.State?
    }

    enum Action: Equatable {
        case ranking(RankingFeature.Action)
        case nicknameSheet(PresentationAction<NicknameFeature.Action>)
        case helpSheet(PresentationAction<HelpFeature.Action>)
        case monsterPaper(PresentationAction<MonsterPaperFeature.Action>)
        case faceResult(FaceResultFeature.Action)

        case cameraTapped
        case faceCaptureDismissed
        case faceCaptureCommitted(SessionBox)
        case faceResultDismissed
        case rankingRowTapped(Monster)
        case editNicknameTapped
        case helpTapped
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.ranking, action: \.ranking) {
            RankingFeature()
        }
        Reduce { state, action in
            switch action {
            case .cameraTapped:
                state.faceCapture = SessionBox()
                return .none

            case .faceCaptureDismissed:
                state.faceCapture = nil
                return .none

            case let .faceCaptureCommitted(box):
                state.faceCapture = nil
                state.faceResult = FaceResultFeature.State(box: box)
                return .none

            case .faceResultDismissed:
                state.faceResult = nil
                return .none

            case let .rankingRowTapped(monster):
                state.monsterPaper = MonsterPaperFeature.State(monster: monster)
                return .none

            case .editNicknameTapped:
                state.nicknameSheet = NicknameFeature.State()
                return .none

            case .helpTapped:
                state.helpSheet = HelpFeature.State()
                return .none

            case let .monsterPaper(.presented(.delegate(.deleted))):
                state.monsterPaper = nil
                return .send(.ranking(.refresh))

            case .faceResult(.delegate(.dismiss)):
                state.faceResult = nil
                return .none

            case .faceResult(.delegate(.registered)):
                return .send(.ranking(.refresh))

            case .ranking, .nicknameSheet, .helpSheet, .monsterPaper, .faceResult:
                return .none
            }
        }
        .ifLet(\.$nicknameSheet, action: \.nicknameSheet) {
            NicknameFeature()
        }
        .ifLet(\.$helpSheet, action: \.helpSheet) {
            HelpFeature()
        }
        .ifLet(\.$monsterPaper, action: \.monsterPaper) {
            MonsterPaperFeature()
        }
        .ifLet(\.faceResult, action: \.faceResult) {
            FaceResultFeature()
        }
    }
}
