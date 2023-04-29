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
}
