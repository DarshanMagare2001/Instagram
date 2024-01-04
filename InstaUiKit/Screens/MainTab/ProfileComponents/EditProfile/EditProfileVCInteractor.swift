//
//  EditProfileVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol EditProfileVCInteractorProtocol {
    var gender : String { get set }
    var countryCode: String { get set }
    var selectedImg : UIImage? { get set }
    var isPrivate : String { get set }
    func saveUserImageToFirebase(image: UIImage,completion: @escaping (Result<URL, Error>) -> Void)
    func saveUserProfileImageToFirebaseDatabase(uid: String, imageUrl: String?, completion: @escaping (Result<Void, Error>) -> Void)
    func saveDataToFirebase(name:String?,username:String?,bio:String?,countryCode:String?,phoneNumber:String?,gender:String? , isPrivate : String?, completionHandler:@escaping(Result<Bool,Error>)->())
}

class EditProfileVCInteractor {
    var gender : String = ""
    var countryCode: String = "+91"
    var selectedImg : UIImage?
    var isPrivate : String = ""
}

extension EditProfileVCInteractor : EditProfileVCInteractorProtocol {
    
    func saveDataToFirebase(name:String?,username:String?,bio:String?,countryCode:String?,phoneNumber:String?,gender:String? , isPrivate : String?, completionHandler:@escaping(Result<Bool,Error>)->()){
        guard let name = name , let username = username , let bio = bio, let countryCode = countryCode , let phoneNumber = phoneNumber , let gender = gender , let isPrivate = isPrivate else { return }
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            self.saveUserToFirebase(uid: uid, name: name, username: username, bio: bio, phoneNumber: phoneNumber, gender: gender, countryCode: countryCode, isPrivate: isPrivate){ result in
                switch result {
                case .success():
                    print("User data saved successfully in database.")
                    FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                        switch result {
                        case .success(let data):
                            if let data = data {
                                self.saveUserInfo(data: data){ value in
                                    print(value)
                                    completionHandler(.success(true))
                                }
                            }
                        case .failure(let failure):
                            print(failure)
                            completionHandler(.failure(failure))
                        }
                    }
                case .failure(let error):
                    print("Error saving user data: \(error)")
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    // Function which save Userimage to firebase
    
    func saveUserImageToFirebase(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            let profileImagesRef = storageRef.child("profile_images/\(uid)")
            let imageFileName = "\(UUID().uuidString).jpg"
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageRef = profileImagesRef.child(imageFileName)
                let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        imageRef.downloadURL { url, error in
                            if let downloadURL = url {
                                completion(.success(downloadURL))
                                print(url)
                            } else {
                                if let error = error {
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
                uploadTask.observe(.progress) { snapshot in
                }
            }
        }
    }
    
    // Function which save Userinfo locally in userdefault
    
    func saveUserInfo(data:UserModel? ,completionHandler:@escaping(Bool) -> Void){
        if let data = data {
            Data.shared.saveData(data.name, key: "Name"){ _ in}
            Data.shared.saveData(data.username, key: "UserName") { _ in}
            Data.shared.saveData(data.bio, key: "Bio") { _ in}
            Data.shared.saveData(data.gender, key: "Gender") { _ in}
            Data.shared.saveData(data.countryCode, key: "CountryCode") { _ in}
            Data.shared.saveData(data.phoneNumber, key: "PhoneNumber") { _ in}
            Data.shared.saveData(data.isPrivate, key: "IsPrivate") { _ in}
            completionHandler(true)
        }else{
            completionHandler(false)
        }
    }
    
    func saveUserProfileImageToFirebaseDatabase(uid: String, imageUrl: String?, completion: @escaping (Result<Void, Error>) -> Void){
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        // Check if the document exists
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                if let imageUrl = imageUrl {
                    userRef.updateData(["imageUrl": imageUrl]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                }
            } else {
                // Handle the case where the user document doesn't exist
                completion(.failure(error as! Error))
            }
        }
    }
    
    
    func saveUserToFirebase(uid: String, name: String?, username: String?, bio: String?, phoneNumber: String?, gender: String?,countryCode : String?,isPrivate:String?,completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let dispatchGroup = DispatchGroup()
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, !document.exists {
                // Document doesn't exist, create it first
                userRef.setData([:]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    updateUserData()
                }
            } else {
                updateUserData()
            }
        }
        
        
        func updateUserData() {
            if let name = name {
                dispatchGroup.enter()
                userRef.updateData(["name": name]) { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    dispatchGroup.leave()
                }
            }
            
            if let username = username {
                dispatchGroup.enter()
                userRef.updateData(["username": username]) { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    dispatchGroup.leave()
                }
                
                if let bio = bio {
                    dispatchGroup.enter()
                    userRef.updateData(["bio": bio]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let phoneNumber = phoneNumber {
                    dispatchGroup.enter()
                    userRef.updateData(["phoneNumber": phoneNumber]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let countryCode = countryCode {
                    dispatchGroup.enter()
                    userRef.updateData(["countryCode": countryCode]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let gender = gender {
                    dispatchGroup.enter()
                    userRef.updateData(["gender": gender]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let isPrivate = isPrivate {
                    dispatchGroup.enter()
                    userRef.updateData(["isPrivate": isPrivate]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(()))
                }
            }
        }
        
    }
    
}
