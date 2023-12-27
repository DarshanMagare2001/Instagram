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



