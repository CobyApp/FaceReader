//
//  FaceMeasureSession.swift
//  FaceReader
//

import UIKit

/// Stable handle for one face-meter flow (TCA-friendly `Equatable` via `id`).
struct SessionBox: Identifiable, Equatable {
    let id: UUID
    let session: FaceMeasureSession

    init(id: UUID = UUID(), session: FaceMeasureSession = FaceMeasureSession()) {
        self.id = id
        self.session = session
    }

    static func == (lhs: SessionBox, rhs: SessionBox) -> Bool {
        lhs.id == rhs.id
    }
}

final class FaceMeasureSession {
    var leftEye: [CGPoint]?
    var rightEye: [CGPoint]?
    var leftEyebrow: [CGPoint]?
    var rightEyebrow: [CGPoint]?
    var nose: [CGPoint]?
    var outerLips: [CGPoint]?
    var innerLips: [CGPoint]?
    var faceContour: [CGPoint]?

    var faceImage: UIImage?
    var cartoonImage: UIImage?

    private(set) var totalScore: Int = 0
    private(set) var grade: Int = 0

    var hasMinimumLandmarksForCapture: Bool {
        leftEye != nil
    }

    func recomputeGradeAndScore() {
        guard let leftEyebrow,
              let rightEye,
              let leftEye,
              let nose,
              let outerLips,
              let faceContour
        else { return }

        let eyeDistance = (rightEye[3].x - leftEye[3].x) as Double
        let eyeWidth = (leftEye[3].x - leftEye[0].x) as Double

        let noseWidth = (nose[5].x - nose[3].x) as Double
        let noseHeight = (nose[4].y - nose[0].y) as Double

        let lipsWidth = (outerLips[7].x - outerLips[13].x) as Double
        let lipsHeight = (outerLips[10].y - outerLips[4].y) as Double

        let faceFirst = (nose[4].y - leftEyebrow[3].y) as Double
        let faceSecond = (faceContour[8].y - nose[4].y) as Double

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
