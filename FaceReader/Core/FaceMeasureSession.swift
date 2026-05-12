//
//  FaceMeasureSession.swift
//  FaceReader
//

import CoreGraphics
import UIKit

/// Stable handle for one face-meter flow (TCA-friendly `Equatable` via `id`).
public struct SessionBox: Identifiable, Equatable {
    public let id: UUID
    public let session: FaceMeasureSession

    public init(id: UUID = UUID(), session: FaceMeasureSession = FaceMeasureSession()) {
        self.id = id
        self.session = session
    }

    public static func == (lhs: SessionBox, rhs: SessionBox) -> Bool {
        lhs.id == rhs.id
    }
}

public final class FaceMeasureSession {
    public var leftEye: [CGPoint]?
    public var rightEye: [CGPoint]?
    public var leftEyebrow: [CGPoint]?
    public var rightEyebrow: [CGPoint]?
    public var nose: [CGPoint]?
    public var outerLips: [CGPoint]?
    public var innerLips: [CGPoint]?
    public var faceContour: [CGPoint]?

    public var faceImage: UIImage?
    public var cartoonImage: UIImage?

    public private(set) var totalScore: Int = 0
    public private(set) var grade: Int = 0

    /// 마지막 `recomputeGradeAndScore` 시 산출된 비율값들 — 정상 비율과 얼마나 어긋났는지를 LLM 프롬프트에 넘기기 위한 스냅샷.
    public struct RatioSnapshot: Equatable, Sendable {
        public let eyeRatio: Double         // 양안거리 / 한쪽 눈 폭 (정상≈1.1)
        public let noseRatio: Double        // 코폭 / 코높이 (정상≈0.6)
        public let lipsRatio: Double        // 입가로 / 입세로 (정상≈2.6)
        public let faceRatio: Double        // 윗얼굴 / 아래얼굴 길이 (정상≈1.1)
    }

    public private(set) var lastRatios: RatioSnapshot?

    public init() {}

    public var hasMinimumLandmarksForCapture: Bool {
        leftEye != nil
    }

    public func recomputeGradeAndScore() {
        guard
            let leftEyebrow, leftEyebrow.count > 3,
            let rightEye, rightEye.count > 3,
            let leftEye, leftEye.count > 3,
            let nose, nose.count > 5,
            let outerLips, outerLips.count > 13,
            let faceContour, faceContour.count > 8
        else { return }

        let eyeDistance = (rightEye[3].x - leftEye[3].x) as Double
        let eyeWidth = (leftEye[3].x - leftEye[0].x) as Double

        let noseWidth = (nose[5].x - nose[3].x) as Double
        let noseHeight = (nose[4].y - nose[0].y) as Double

        let lipsWidth = (outerLips[7].x - outerLips[13].x) as Double
        let lipsHeight = (outerLips[10].y - outerLips[4].y) as Double

        let faceFirst = (nose[4].y - leftEyebrow[3].y) as Double
        let faceSecond = (faceContour[8].y - nose[4].y) as Double

        guard eyeWidth != 0, noseHeight != 0, lipsHeight != 0, faceSecond != 0 else { return }

        let eyeRatio = eyeDistance / eyeWidth
        let noseRatio = noseWidth / noseHeight
        let lipsRatio = lipsWidth / lipsHeight
        let faceRatio = faceFirst / faceSecond

        lastRatios = RatioSnapshot(
            eyeRatio: eyeRatio,
            noseRatio: noseRatio,
            lipsRatio: lipsRatio,
            faceRatio: faceRatio
        )

        // 기존 가중치(20_000 / 20_000 / 10_000 / 20_000)는 정상 얼굴도 즉시 30M+ 로 치솟아
        // 거의 모두 신급/용급으로 가는 문제 → ~25% 수준으로 낮춰 보수적으로 계산.
        let eyeRatioScore = Int(abs(eyeRatio - 1.1) * 5_000) * 1_000
        let noseRatioScore = Int(abs(noseRatio - 0.6) * 5_000) * 1_000
        let lipsRatioScore = Int(abs(lipsRatio - 2.6) * 2_500) * 1_000
        let faceRatioScore = Int(abs(faceRatio - 1.1) * 5_000) * 1_000

        let score = eyeRatioScore + noseRatioScore + lipsRatioScore + faceRatioScore
        totalScore = score

        // 임계값도 같이 조정: 가만히 있으면 늑대/호랑이, 일그러뜨려야 위로 올라감.
        if score < 2_000_000 {
            grade = 0       // 늑대급
        } else if score < 5_000_000 {
            grade = 1       // 호랑이급
        } else if score < 9_000_000 {
            grade = 2       // 귀급
        } else if score < 15_000_000 {
            grade = 3       // 용급
        } else {
            grade = 4       // 신급
        }
    }
}
