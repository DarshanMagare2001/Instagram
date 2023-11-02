//
//  FetchUserInfo.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import Foundation
import FirebaseFirestore

class FetchUserInfo {
    static let shared = FetchUserInfo()
    private init() {
        
    }
    
    // MARK: - Fetch Unique Users
    
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
                                if let imageURL = document["imageUrl"] as? String,
                                   let bio = document["bio"] as? String,
                                   let countryCode = document["countryCode"] as? String,
                                   let fcmToken = document["fcmToken"] as? String,
                                   let gender = document["gender"] as? String,
                                   let name = document["name"] as? String,
                                   let phoneNumber = document["phoneNumber"] as? String,
                                   let uid = document["uid"] as? String,
                                   let username = document["username"] as? String {
                                    if uid != currentUid { // Check if the uid is not the current user's uid
                                        let user = UserModel(uid: uid, bio: bio, fcmToken: fcmToken, phoneNumber: phoneNumber, countryCode: countryCode, name: name, imageUrl: imageURL, gender: gender, username: username)
                                        users.append(user)
                                        print(users)
                                    }
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


}
