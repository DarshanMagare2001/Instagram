//
//  FetchUserInfo.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import Foundation
import FirebaseFirestore
import Firebase

class FetchUserInfo {
    static let shared = FetchUserInfo()
    private init() {
        
    }
    
    // MARK: - Fetch Unique Users From Firebase
    
    func fetchUniqueUsersFromFirebase(completionHandler: @escaping (Result<[UserModel], Error>) -> Void) {
        Data.shared.getData(key: "CurrentUserId") { (result: Result<String?, Error>) in
            switch result {
            case .success(let currentUid):
                let db = Firestore.firestore()
                db.collection("users")
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching users: \(error.localizedDescription)")
                            completionHandler(.failure(error))
                        } else {
                            var users: [UserModel] = []
                            for document in querySnapshot!.documents {
                                print("Fetched user document: \(document.data())")
                                let imageURL = document["imageUrl"] as? String
                                let bio = document["bio"] as? String
                                let countryCode = document["countryCode"] as? String
                                let fcmToken = document["fcmToken"] as? String
                                let gender = document["gender"] as? String
                                let name = document["name"] as? String
                                let phoneNumber = document["phoneNumber"] as? String
                                let uid = document["uid"] as? String
                                let username = document["username"] as? String
                                let followers = document["followers"] as? [String]
                                let followings = document["followings"] as? [String]
                                if uid != currentUid { // Check if the uid is not the current user's uid
                                    let user = UserModel(uid: uid ?? "", bio: bio ?? "", fcmToken: fcmToken ?? "", phoneNumber: phoneNumber ?? "", countryCode: countryCode ?? "", name: name ?? "", imageUrl: imageURL ?? "", gender: gender ?? "", username: username ?? "", followers : followers ?? [] , followings: followings ?? [])
                                    users.append(user)
                                    print(users)
                                }
                                
                            }
                            DispatchQueue.main.async {
                                completionHandler(.success(users))
                            }
                        }
                    }
            case .failure(let failure):
                print(failure)
                completionHandler(.failure(failure))
            }
        }
    }
    
    // MARK: - Fetch CurrentUser From Firebase
    
    func fetchCurrentUserFromFirebase(completionHandler: @escaping (Result<UserModel?, Error>) -> Void) {
        Data.shared.getData(key: "CurrentUserId") { (result: Result<String?, Error>) in
            switch result {
            case .success(let currentUid):
                if let currentUid = currentUid{
                    let db = Firestore.firestore()
                    db.collection("users").document(currentUid).getDocument { (document, error) in
                        if let error = error {
                            print("Error fetching current user: \(error.localizedDescription)")
                            completionHandler(.failure(error))
                        } else if let document = document, document.exists {
                            print("Fetched current user document: \(document.data())")
                            let imageURL = document["imageUrl"] as? String
                            let bio = document["bio"] as? String
                            let countryCode = document["countryCode"] as? String
                            let fcmToken = document["fcmToken"] as? String
                            let gender = document["gender"] as? String
                            let name = document["name"] as? String
                            let phoneNumber = document["phoneNumber"] as? String
                            let uid = document["uid"] as? String
                            let username = document["username"] as? String
                            let followers = document["followers"] as? [String]
                            let followings = document["followings"] as? [String]
                            let user = UserModel(uid: uid ?? "", bio: bio ?? "", fcmToken: fcmToken ?? "", phoneNumber: phoneNumber ?? "", countryCode: countryCode ?? "", name: name ?? "", imageUrl: imageURL ?? "", gender: gender ?? "", username: username ?? "", followers : followers ?? [] , followings: followings ?? [])
                            DispatchQueue.main.async {
                                completionHandler(.success(user))
                            }
                        } else {
                            // User document not found
                            DispatchQueue.main.async {
                                completionHandler(.success(nil))
                            }
                        }
                    }
                }
            case .failure(let failure):
                print(failure)
                completionHandler(.failure(failure))
            }
        }
    }
    
    
    // MARK: - Fetch FMCToken
    
    func getFCMToken(completion: @escaping (String?) -> Void) {
        // Check if Firebase is configured
        guard let _ = FirebaseApp.app() else {
            completion(nil)
            return
        }
        // Get the FCM token
        if let token = Messaging.messaging().fcmToken {
            completion(token)
        } else {
            // FCM token not available, try to refresh it
            Messaging.messaging().token { token, error in
                if let token = token {
                    completion(token)
                } else {
                    completion(nil)
                    print("Error fetching FCM token: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    
}
