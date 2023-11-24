//
//  UserInfo.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/11/23.
//

import Foundation
import FirebaseFirestore

class StoreUserInfo {
    static let shared = StoreUserInfo()
    private init(){}
    
    // MARK: - Save Users FMCToken And Uid
    
    func saveUsersFMCTokenAndUidToFirebase(uid: String, fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        // Create a dictionary with both the uid and fcmToken
        let data: [String: Any] = ["uid": uid, "fcmToken": fcmToken]
        // Set the document with the combined data
        userRef.setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Save User's Followers
    
    
    func saveFollowersToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(toFollowsUid)
        // Update the document with the followings UID
        userRef.setData(["followers": FieldValue.arrayUnion([whoFollowingsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

   
}
