//
//  SignUpVCViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVCViewModel {
    var viewModel = AuthenticationViewModel()
    var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func signUp(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Bool) -> Void) {
        LoaderVCViewModel.shared.showLoader()
        guard let email = emailTxtFld, let password = passwordTxtFld, !email.isEmpty, !password.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Alert.shared.alertOk(title: "Warning!", message: "Please fill in all the required fields before proceeding.", presentingViewController: self.presentingViewController!)
            }
            completionHandler(false)
            return
        }
        viewModel.signUp(email: email, password: password) { error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Alert.shared.alertOk(title: "Error!", message: error.localizedDescription, presentingViewController: self.presentingViewController!)
                }
                completionHandler(false)
            } else {
                print("Sign Up Successfuly")
                if let uid = Auth.auth().currentUser?.uid {
                    print(uid)
                    Data.shared.saveData(uid, key: "CurrentUserId") { value in
                        print(value)
                        let userDefaults = UserDefaults.standard
                        userDefaults.removeObject(forKey: "Name")
                        userDefaults.removeObject(forKey: "UserName")
                        userDefaults.removeObject(forKey: "Bio")
                        userDefaults.removeObject(forKey: "Gender")
                        userDefaults.removeObject(forKey: "CountryCode")
                        userDefaults.removeObject(forKey: "PhoneNumber")
                        userDefaults.removeObject(forKey: "ProfileUrl")
                        userDefaults.synchronize()
                        completionHandler(true)
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
