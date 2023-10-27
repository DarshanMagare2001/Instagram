//
//  SignInVCViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import Foundation
import UIKit

class SignInVCViewModel {
    var viewModel = AuthenticationViewModel()
    var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func login(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Bool) -> Void) {
        guard let email = emailTxtFld, let password = passwordTxtFld, !email.isEmpty, !password.isEmpty else {
            // Email or password is empty, show the warning alert
            Alert.shared.alert(title: "Warning!", message: "Please fill in all the required fields before proceeding.", presentingViewController: presentingViewController!)
            completionHandler(false)
            return
        }
        
        viewModel.signIn(email: email, password: password) { error in
            if let error = error {
                print(error.localizedDescription)
                Alert.shared.alert(title: "Error!", message: error.localizedDescription, presentingViewController: self.presentingViewController!)
                completionHandler(false)
            } else {
                print("Sign In Successfully")
                completionHandler(true)
            }
        }
    }
    
}


