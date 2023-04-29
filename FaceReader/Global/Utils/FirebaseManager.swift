//
//  FirebaseManager.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager: NSObject {
    static let shared = FirebaseManager()

    let auth: Auth
    let storage: Storage
    let store: Firestore

    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.store = Firestore.firestore()

        super.init()
    }
    
    func createMonster(nickname: String, password: String, image: UIImage) async {
        do {
            let uid = "\(nickname)_\(FaceManager.totalScore)"
            let ref = storage.reference(withPath: uid)
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            _ = try await ref.putDataAsync(imageData, metadata: nil)
            let imageUrl = try await ref.downloadURL().absoluteString

            let monsterData = [
                "nickname": nickname,
                "password": password,
                "imageUrl": imageUrl,
                "grade": FaceManager.grade,
                "score": FaceManager.totalScore
            ] as [String : Any]

            try await store.collection("monsters").document(uid).setData(monsterData)
        } catch {
            print("Failed to create Meeting")
        }
    }
}
