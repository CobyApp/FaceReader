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

    // MARK: - Scoring

    /// 정상값(target)과 가중치(weight)를 한 곳에 모아 둠.
    /// 가중치는 보수적으로 — 가만히 있는 얼굴은 늑대급에 머무르고, 얼굴을 일그러뜨려야 위로 올라가도록.
    private static let eyeTarget: Double = 1.1
    private static let noseTarget: Double = 0.6
    private static let lipsTarget: Double = 2.6
    private static let faceTarget: Double = 1.1

    private static let eyeWeight: Double = 2_500   // 양안거리 비율
    private static let noseWeight: Double = 2_500  // 코폭/코높이
    private static let lipsWeight: Double = 1_200  // 입가로/입세로 (편차 폭이 가장 커서 가중치 낮음)
    private static let faceWeight: Double = 2_500  // 윗얼굴/아래얼굴

    /// 등급 경계 — score 가 (-inf, t0) → 늑대, [t0, t1) → 호랑이, ..., [t3, +inf) → 신.
    private static let gradeThresholds: [Int] = [
        2_500_000,   // < 2.5M  → 늑대급
        6_000_000,   // < 6M    → 호랑이급
        12_000_000,  // < 12M   → 귀급
        22_000_000,  // < 22M   → 용급
                     // ≥ 22M   → 신급
    ]

    private static func score(eyeRatio: Double, noseRatio: Double, lipsRatio: Double, faceRatio: Double) -> Int {
        let parts: [(Double, Double, Double)] = [
            (eyeRatio, eyeTarget, eyeWeight),
            (noseRatio, noseTarget, noseWeight),
            (lipsRatio, lipsTarget, lipsWeight),
            (faceRatio, faceTarget, faceWeight),
        ]
        let raw = parts.reduce(0) { acc, p in
            acc + Int(abs(p.0 - p.1) * p.2) * 1_000
        }
        return raw
    }

    private static func grade(forScore score: Int) -> Int {
        for (i, threshold) in gradeThresholds.enumerated() {
            if score < threshold { return i }
        }
        return gradeThresholds.count // 4 = 신급
    }

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

        totalScore = Self.score(
            eyeRatio: eyeRatio,
            noseRatio: noseRatio,
            lipsRatio: lipsRatio,
            faceRatio: faceRatio
        )
        grade = Self.grade(forScore: totalScore)
    }
}
