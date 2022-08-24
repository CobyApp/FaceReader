//
//  FaceManager.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

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
    
    static var eyeDistance: Double? = nil
    static var eyeWidth: Double? = nil
    static var eyeHeight: Double? = nil
    
    static var noseWidth: Double? = nil
    static var noseHeight: Double? = nil
    
    static var lipsWidth: Double? = nil
    static var lipsHeight: Double? = nil
    
    static var faceFirst: Double? = nil
    static var faceSecond: Double? = nil
    
    static var eyeRatio: Double? = nil
    static var noseRatio: Double? = nil
    static var lipsRatio: Double? = nil
    static var faceRatio: Double? = nil
    
    static var eyeRatioScore: Int = 0
    static var noseRatioScore: Int = 0
    static var lipsRatioScore: Int = 0
    static var faceRatioScore: Int = 0
    
    static var totalScore: Int = 0

    static var grade: Int = 0
    
    func setValues() {
        // eye
        FaceManager.eyeDistance = (FaceManager.rightEye![3].x - FaceManager.leftEye![3].x) as Double
        FaceManager.eyeWidth = (FaceManager.leftEye![3].x - FaceManager.leftEye![0].x) as Double
        FaceManager.eyeHeight = (FaceManager.leftEye![5].y - FaceManager.leftEye![1].y) as Double
        
        // nose
        FaceManager.noseWidth = (FaceManager.nose![5].x - FaceManager.nose![3].x) as Double
        FaceManager.noseHeight = (FaceManager.nose![4].y - FaceManager.nose![0].y) as Double
        
        // lips
        FaceManager.lipsWidth = (FaceManager.outerLips![7].x - FaceManager.outerLips![13].x) as Double
        FaceManager.lipsHeight = (FaceManager.outerLips![10].y - FaceManager.outerLips![4].y) as Double
        
        // face
        FaceManager.faceFirst = (FaceManager.nose![4].y - FaceManager.leftEyebrow![3].y) as Double
        FaceManager.faceSecond = (FaceManager.faceContour![8].y - FaceManager.nose![4].y) as Double
        
        // ratio
        FaceManager.eyeRatio = FaceManager.eyeDistance! / FaceManager.eyeWidth! // 1에 가까워야함 -> 1.1
        FaceManager.noseRatio = FaceManager.noseWidth! / FaceManager.noseHeight! // 0.64에 가까워야함 -> 0.6
        FaceManager.lipsRatio = FaceManager.lipsWidth! / FaceManager.lipsHeight! // 3에 가까워야함 -> 2.4
        FaceManager.faceRatio = FaceManager.faceFirst! / FaceManager.faceSecond! // 1에 가까워야함 -> 1.1
        
        FaceManager.eyeRatioScore = Int(abs(FaceManager.eyeRatio! - 1.1) * 10000)
        FaceManager.noseRatioScore = Int(abs(FaceManager.noseRatio! - 0.6) * 10000)
        FaceManager.lipsRatioScore = Int(abs(FaceManager.lipsRatio! - 2.4) * 10000)
        FaceManager.faceRatioScore = Int(abs(FaceManager.faceRatio! - 1.1) * 10000)
        
        FaceManager.totalScore = FaceManager.eyeRatioScore + FaceManager.noseRatioScore + FaceManager.lipsRatioScore + FaceManager.faceRatioScore
        
        if FaceManager.totalScore < 8000 {
            FaceManager.grade = 0
        } else if FaceManager.totalScore < 12000 {
            FaceManager.grade = 1
        } else if FaceManager.totalScore < 16000 {
            FaceManager.grade = 2
        } else if FaceManager.totalScore < 20000 {
            FaceManager.grade = 3
        } else {
            FaceManager.grade = 4
        }
        
        print(FaceManager.totalScore)
    }
    
    private init() { }
}

let gradeData: [[String: String]] = [
    [
        "grade": "낭(狼)",
        "info": "위험인자가 될 집단의 출현"
    ],
    [
        "grade": "호(虎)",
        "info": "불특정 다수의 생명의 위기"
    ],
    [
        "grade": "귀(鬼)",
        "info": "도시 전체의 기능정지 및 괴멸 위기"
    ],
    [
        "grade": "용(龍)",
        "info": "도시 여러개가 괴멸 당할 위기"
    ],
    [
        "grade": "신(神)",
        "info": "인류멸망의 위기"
    ],
]
