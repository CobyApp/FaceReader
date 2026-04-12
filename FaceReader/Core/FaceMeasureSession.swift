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
ㅣ한ㅂ
        guard eyeWidth != 0, noseHeight != 0, lipsHeight != 0, faceSecond != 0 else { return }

        let eyeRatio = eyeDistance / eyeWidth
        let noseRatio = noseWidth / noseHeight
        let lipsRatio = lipsWidth / lipsHeight
        let faceRatio = faceFirst / faceSecond

        let eyeRatioScore = Int(abs(eyeRatio - 1.1) * 20_000) * 1_000
        let noseRatioScore = Int(abs(noseRatio - 0.6) * 20_000) * 1_000
        let lipsRatioScore = Int(abs(lipsRatio - 2.6) * 10_000) * 1_000
        let faceRatioScore = Int(abs(faceRatio - 1.1) * 20_000) * 1_000

        let score = eyeRatioScore + noseRatioScore + lipsRatioScore + faceRatioScore
        totalScore = score

        if score < 10_000_000 {
            grade = 0
        } else if score < 15_000_000 {
            grade = 1
        } else if score < 20_000_000 {
            grade = 2
        } else if score < 30_000_000 {
            grade = 3
        } else {
            grade = 4
        }
    }
}
