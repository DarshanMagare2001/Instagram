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
        // Check if the document exists
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                // Document exists, update the FCM token
                userRef.updateData(["fcmToken": fcmToken]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                
                userRef.updateData(["uid": uid]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                
            } else {
                // Document doesn't exist, create it first
                userRef.setData(["fcmToken": fcmToken]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                
                userRef.setData(["uid": uid]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                
            }
        }
    }
    
    
    
    
    
}
