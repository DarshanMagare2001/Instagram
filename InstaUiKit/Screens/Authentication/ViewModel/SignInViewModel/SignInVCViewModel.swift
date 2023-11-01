//
//  SignInVCViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInVCViewModel {
    var viewModel = AuthenticationViewModel()
    var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func login(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Bool) -> Void) {
        LoaderVCViewModel.shared.showLoader()
        guard let email = emailTxtFld, let password = passwordTxtFld, !email.isEmpty, !password.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Alert.shared.alertOk(title: "Warning!", message: "Please fill in all the required fields before proceeding.", presentingViewController: self.presentingViewController!)
            }
            completionHandler(false)
            return
        }
        
        viewModel.signIn(email: email, password: password) { error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Alert.shared.alertOk(title: "Error!", message: error.localizedDescription, presentingViewController: self.presentingViewController!)
                }
                completionHandler(false)
            } else {
                print("Sign In Successfully")
                if let uid = Auth.auth().currentUser?.uid {
                    print(uid)
                    Data.shared.saveData(uid, key: "CurrentUserId") { value in
                        print(value)
                        EditProfileViewModel.shared.fetchUserProfileImageURL { result in
                            switch result {
                            case .success(let url):
                                if let urlString = url?.absoluteString {
                                    Data.shared.saveData(urlString, key: "ProfileUrl") { (value: Bool) in
                                    }
                                }
                            case.failure(let error):
                                print(error)
                            }
                        }
                        
                        EditProfileViewModel.shared.fetchUserData { result in
                            switch result {
                            case .success(let data):
                                print(data)
                                Data.shared.saveData(data.name, key: "Name"){ _ in}
                                Data.shared.saveData(data.username, key: "UserName") { _ in}
                                Data.shared.saveData(data.bio, key: "Bio") { _ in}
                                Data.shared.saveData(data.gender, key: "Gender") { _ in}
                                Data.shared.saveData(data.countryCode, key: "CountryCode") { _ in}
                                Data.shared.saveData(data.phoneNumber, key: "PhoneNumber") { _ in}
                                completionHandler(true)
                            case.failure(let error):
                                print(error)
                                completionHandler(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveUserFCMTokenToFirebase(uid: String, fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
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

