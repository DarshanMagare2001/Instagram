//
//  AuthenticationModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import FirebaseAuth


//This is authentication model class for all authentication

class AuthenticationViewModel {
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                // Handle sign-up error
                print("Sign-up error: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Sign-up successful
            // You can access the user's unique identifier with authResult?.user.uid
            
            print("Sign-up successful with email: \(email)")
            // Perform any additional operations after successful sign-up
            
            completion(nil)
        }
    }

    // MARK: - Sign In
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                // Handle sign-in error
                print("Sign-in error: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Sign-in successful
            // You can access the user's unique identifier with authResult?.user.uid
            
            print("Sign-in successful with email: \(email)")
            // Perform any additional operations after successful sign-in
            
            completion(nil)
        }
    }
    
    
    // MARK: - Get Current User Email
    
    func getCurrentUserEmail() -> String? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.email
        } else {
            return nil
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        do {
            try Auth.auth().signOut()
            print("Logout successful")
            // Perform any additional operations after successful logout
        } catch {
            // Handle logout error
            print("Logout error: \(error.localizedDescription)")
        }
    }
    
}



