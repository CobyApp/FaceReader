//
//  FaceManager.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

import Alamofire
import Foundation

final class FaceManager {
    
    static let shared = FaceManager()
    
    static var leftEye: [CGPoint]? = nil
    static var rightEye: [CGPoint]? = nil
    static var leftEyebrow: [CGPoint]? = nil
    static var rightEyebrow: [CGPoint]? = nil
    static var nose: [CGPoint]? = nil
    static var outerLips: [CGPoint]? = nil
    static var innerLips: [CGPoint]? = nil
    static var faceContour: [CGPoint]? = nil
    
    static var faceImage: UIImage? = nil
    static var cartoonImage: UIImage? = nil
    
    static var totalScore: Int = 0
    static var grade: Int = 0
    
    func setValues() {
        guard let leftEyebrow = FaceManager.leftEyebrow else { return }
        guard let rightEye = FaceManager.rightEye else { return }
        guard let leftEye = FaceManager.leftEye else { return }
        guard let nose = FaceManager.nose else { return }
        guard let outerLips = FaceManager.outerLips else { return }
        guard let faceContour = FaceManager.faceContour else { return }
        
        // eye
        let eyeDistance = (rightEye[3].x - leftEye[3].x) as Double
        let eyeWidth = (leftEye[3].x - leftEye[0].x) as Double
        
        // nose
        let noseWidth = (nose[5].x - nose[3].x) as Double
        let noseHeight = (nose[4].y - nose[0].y) as Double
        
        // lips
        let lipsWidth = (outerLips[7].x - outerLips[13].x) as Double
        let lipsHeight = (outerLips[10].y - outerLips[4].y) as Double
        
        // face
        let faceFirst = (nose[4].y - leftEyebrow[3].y) as Double
        let faceSecond = (faceContour[8].y - nose[4].y) as Double
        
        // ratio
        let eyeRatio = eyeDistance / eyeWidth // 1에 가까워야함 -> 1.1
        let noseRatio = noseWidth / noseHeight // 0.64에 가까워야함 -> 0.6
        let lipsRatio = lipsWidth / lipsHeight // 3에 가까워야함 -> 2.6
        let faceRatio = faceFirst / faceSecond // 1에 가까워야함 -> 1.1
        
        // score
        let eyeRatioScore = Int(abs(eyeRatio - 1.1) * 20000) * 1000
        let noseRatioScore = Int(abs(noseRatio - 0.6) * 20000) * 1000
        let lipsRatioScore = Int(abs(lipsRatio - 2.6) * 10000) * 1000
        let faceRatioScore = Int(abs(faceRatio - 1.1) * 20000) * 1000
        
        FaceManager.totalScore = eyeRatioScore + noseRatioScore + lipsRatioScore + faceRatioScore
        
        if FaceManager.totalScore < 10000000 {
            FaceManager.grade = 0
        } else if FaceManager.totalScore < 15000000 {
            FaceManager.grade = 1
        } else if FaceManager.totalScore < 20000000 {
            FaceManager.grade = 2
        } else if FaceManager.totalScore < 30000000 {
            FaceManager.grade = 3
        } else {
            FaceManager.grade = 4
        }
    }
    
    private init() { }
}
