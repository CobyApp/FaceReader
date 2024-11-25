//
//  FirebaseManager.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

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
            let uid = UUID().uuidString
            let ref = storage.reference(withPath: uid)
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            _ = try await ref.putDataAsync(imageData, metadata: nil)
            let imageUrl = try await ref.downloadURL().absoluteString
            let (year, month, day) = Date().dateToString

            let monsterData = [
                "uid": uid,
                "nickname": nickname,
                "password": password,
                "imageUrl": imageUrl,
                "grade": FaceManager.grade,
                "score": FaceManager.totalScore,
                "year": year,
                "month": month,
                "day": day
            ] as [String : Any]

            try await store.collection("monsters").document(uid).setData(monsterData)
        } catch {
            print("Failed to create Monster")
        }
    }
    
    func loadMonsters(term: Int, pages: Int) async -> (monsters: [Monster], cursor: QueryDocumentSnapshot?)? {
        do {
            var querySnapshot: QuerySnapshot
            let (year, month, day) = Date().dateToString
            
            switch term {
            case 0:
                querySnapshot = try await store
                    .collection("monsters")
                    .whereField("year", isEqualTo: year)
                    .whereField("month", isEqualTo: month)
                    .whereField("day", isEqualTo: day)
                    .order(by: "score", descending: true)
                    .limit(to: pages)
                    .getDocuments()
            case 1:
                querySnapshot = try await store
                    .collection("monsters")
                    .whereField("year", isEqualTo: year)
                    .whereField("month", isEqualTo: month)
                    .order(by: "score", descending: true)
                    .limit(to: pages)
                    .getDocuments()
            case 2:
                querySnapshot = try await store
                    .collection("monsters")
                    .whereField("year", isEqualTo: year)
                    .order(by: "score", descending: true)
                    .limit(to: pages)
                    .getDocuments()
            default:
                querySnapshot = try await store
                    .collection("monsters")
                    .order(by: "score", descending: true)
                    .limit(to: pages)
                    .getDocuments()
            }
            
            let monsters = try querySnapshot.documents.compactMap { doc -> Monster? in
                try doc.data(as: Monster.self)
            }
            
            let cursor = querySnapshot.count < pages ? nil : querySnapshot.documents.last
            
            return (monsters, cursor)
        } catch {
            print("error to load Monster")
            return nil
        }
    }
    
    func continueMonsters(term: Int, cursor: DocumentSnapshot, pages: Int) async -> (monsters: [Monster], cursor: QueryDocumentSnapshot?)? {
        do {
            var querySnapshot: QuerySnapshot
            let (year, month, day) = Date().dateToString
            
            switch term {
            case 0:
                querySnapshot = try await store
                    .collection("monsters")
                    .whereField("year", isEqualTo: year)
                    .whereField("month", isEqualTo: month)
                    .whereField("day", isEqualTo: day)
                    .order(by: "score", descending: true)
                    .start(afterDocument: cursor)
                    .limit(to: pages)
                    .getDocuments()
            case 1:
                querySnapshot = try await store
                    .collection("monsters")
                    .whereField("year", isEqualTo: year)
                    .whereField("month", isEqualTo: month)
                    .order(by: "score", descending: true)
                    .start(afterDocument: cursor)
                    .limit(to: pages)
                    .getDocuments()
            case 2:
                querySnapshot = try await store
                    .collection("monsters")
                    .whereField("year", isEqualTo: year)
                    .order(by: "score", descending: true)
                    .start(afterDocument: cursor)
                    .limit(to: pages)
                    .getDocuments()
            default:
                querySnapshot = try await store
                    .collection("monsters")
                    .order(by: "score", descending: true)
                    .start(afterDocument: cursor)
                    .limit(to: pages)
                    .getDocuments()
            }
            
            let monsters = try querySnapshot.documents.compactMap { doc -> Monster? in
                try doc.data(as: Monster.self)
            }
            
            let cursor = querySnapshot.count < pages ? nil : querySnapshot.documents.last
            
            return (monsters, cursor)
        } catch {
            print("error to continue Monster")
            return nil
        }
    }
    
    func deleteMonster(monster: Monster) async {
        do {
            let ref = storage.reference(forURL: monster.imageUrl)
            try await ref.delete()
            try await store.collection("monsters").document(monster.uid).delete()
        } catch {
            print("error to delete Monster")
        }
    }
}
