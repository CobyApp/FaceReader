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
    
    func postImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let URL = "https://master-white-box-cartoonization-psi1104.endpoint.ainize.ai/predict"
        let header : HTTPHeaders = [
            "accept": "image/jpg",
            "Content-Type" : "multipart/form-data"
        ]
        let parameters: [String : Any] = [
            "file_type" : "image"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = FaceManager.faceImage?.pngData() {
                multipartFormData.append(image, withName: "source", fileName: "\(image).png", mimeType: "image/png")
            }
        }, to: URL, usingThreshold: UInt64.init(), method: .post, headers: header).response { response in
            switch response.result {
            case .success(let value):
                guard let cartoonImage = UIImage(data: value!) else {
                    completion(.success(FaceManager.faceImage!))
                    return
                }
                completion(.success(cartoonImage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private init() { }
}

let gradeData: [[String: Any]] = [
    [
        "grade": "낭(狼)",
        "info": "위험인자가 될 집단의 출현",
        "detail": "C급 히어로들 혹은 B급 히어로 선에서 처리가 가능한 레벨. 히어로 협회에서 공표한 계급별 전투력 비교에 따르면 C급 히어로 3인, B급 히어로 1인이 상대 가능한 레벨. C급 중에서도 강한 히어로는 단독으로 상대가 가능하며 B급 중에서도 강한 경우 낭급 다수를 상대로 무쌍을 찍을 수 있다.",
        "image": ImageLiterals.wolf
    ],
    [
        "grade": "호(虎)",
        "info": "불특정 다수의 생명의 위기",
        "detail": "A급 히어로가 단신으로 감당할 수 있는 레벨 한계선. 다만 호급 괴인들 중에서도 강한 녀석들은 웬만한 A급 중하위권 히어로쯤은 가볍게 압도할 수 있으며 상성에 따라서는 A급 중위권 이상의 히어로도 패배할 수 있다. 반대로 A급 상위권이 호급 여러 마리를 혼자서 처치하는 일도 있긴 하다.",
        "image": ImageLiterals.tiger
    ],
    [
        "grade": "귀(鬼)",
        "info": "도시 전체의 기능정지 및 괴멸 위기",
        "detail": "한 마리로도 상당한 수의 통상적인 히어로들이 철저한 준비와 작전을 세워서 목숨 걸고 싸워야 하는 레벨. 귀급부터는 전투력이 도시 하나를 위협할 만큼 강해지기에 1개 사단 이상, 혹은 다수의 A급 히어로나 S급 히어로가 출동해야 한다.",
        "image": ImageLiterals.demon
    ],
    [
        "grade": "용(龍)",
        "info": "도시 여러개가 괴멸 당할 위기",
        "detail": "전례가 없는 신을 제외하면 가장 피해 규모가 높은 레벨. 도시 여럿을 위협하는 단계의 피해가 예상되면 용급으로 격상한다. 여기서부턴 통상적인 재래식 군대로는 대응이 어렵고, S급 히어로들 조차도 대부분 상대가 되지 않거나 되더라도 1:1에서 패배하거나 상당히 고전할 정도로 강한 등급이다.",
        "image": ImageLiterals.dragon
    ],
    [
        "grade": "신(神)",
        "info": "인류멸망의 위기",
        "detail": "S급은 커녕 현존 인류 전원이 달려들어도 이길 수 없는 말그대로 신이나 다름없는 존재. 신급의 경우 '인류 멸망의 위기'라는 단서가 붙어있는 전무후무한 괴인이기 때문에 비교를 통한 추정조차 불가능하다. 어쩌면 인류멸망 직전에서야 붙혀지는 등급일지도 모른다.",
        "image": ImageLiterals.god
    ],
]
