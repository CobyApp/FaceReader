//
//  FaceResultFeature.swift
//  FaceReader
//

import ComposableArchitecture
import FaceReaderCore
import Foundation

@Reducer
public struct FaceResultFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var box: SessionBox
        public var posterImageData: Data?
        /// AI 가 만든 빌런 이름 + 도감 본문. nil 이면 LLM 미지원/실패.
        public var report: ReportPayload?

        public init(box: SessionBox, posterImageData: Data? = nil, report: ReportPayload? = nil) {
            self.box = box
            self.posterImageData = posterImageData
            self.report = report
        }
    }

    public struct ReportPayload: Equatable, Sendable {
        public let codename: String
        public let description: String
        public init(codename: String, description: String) {
            self.codename = codename
            self.description = description
        }
    }

    public enum Action: Equatable {
        case onAppear
        case dismissTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismiss
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            case .dismissTapped:
                return .send(.delegate(.dismiss))
            case .delegate:
                return .none
            }
        }
    }
}
