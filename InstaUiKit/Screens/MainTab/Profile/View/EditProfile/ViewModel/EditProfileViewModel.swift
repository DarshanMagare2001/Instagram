//
//  EditProfileViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/08/23.
//

import Foundation
import FirebaseAuth
import UIKit

class EditProfileViewModel {
    static let shared = EditProfileViewModel()
    var eventHandler: ((_ event : Event) -> Void)?
    var userModel: ProfileModel?
    init(){
        fetchProfile()
    }
    
    func fetchProfile(){
        if let uid = Auth.auth().currentUser?.uid {
            self.eventHandler?(.loading)
            ProfileViewModel.shared.fetchUserData(uid: uid) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let profileModel):
                    print("Fetched user data successfully\(profileModel)")
                    self.userModel = profileModel
                    self.eventHandler?(.loaded)
                case .failure(let error):
                    print("Error fetching user data: \(error)")
                    self.eventHandler?(.error(error))
                }
            }
        }
    }
    
    func saveProfileToUserDefaults(uid: String, name: String?, username: String?, bio: String?, phoneNumber: String?, gender: String?, countryCode : String? , completion: @escaping (Result<Void, Error>) -> Void) {
        UserDefaults.standard.set(uid, forKey: "uid")
        
        if name != "" {
            if let name = name {
                UserDefaults.standard.set(name, forKey: "name")
            }
        }
        
        if username != "" {
            if let username = username {
                UserDefaults.standard.set(username, forKey: "username")
            }
        }
        
        
        if bio != "" {
            if let bio = bio {
                UserDefaults.standard.set(bio, forKey: "bio")
            }
        }
        
        
        if phoneNumber != "" {
            if let phoneNumber = phoneNumber {
                UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
            }
        }
        
        
        if gender != "" {
            if let gender = gender {
                UserDefaults.standard.set(gender, forKey: "gender")
            }
        }
        
        if countryCode != "" {
            if let countryCode = countryCode {
                UserDefaults.standard.set(countryCode, forKey: "countryCode")
            }
        }
        
        // Call the completion block with a successful result
        completion(.success(()))
    }
    
    func fetchProfileFromUserDefaults(completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "name") ?? ""
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let bio = UserDefaults.standard.string(forKey: "bio") ?? ""
        let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") ?? ""
        let gender = UserDefaults.standard.string(forKey: "gender") ?? ""
        let countryCode = UserDefaults.standard.string(forKey: "countryCode") ?? ""
        
        let dictionary: [String: Any] = [
            "uid": uid,
            "name": name,
            "username": username,
            "bio": bio,
            "phoneNumber": phoneNumber,
            "gender": gender,
            "countryCode":countryCode,
            "imageURL": ""
        ]
        
        if let profileData = ProfileModel(dictionary: dictionary) {
            // Call the completion block with the fetched profile data
            completion(.success(profileData))
        } else {
            // Handle initialization failure
            let error = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize ProfileModel"])
            completion(.failure(error))
        }
    }
    
    
}

extension EditProfileViewModel {
    enum Event {
        case loading
        case stopLoading
        case loaded
        case error(Error?)
    }
}
