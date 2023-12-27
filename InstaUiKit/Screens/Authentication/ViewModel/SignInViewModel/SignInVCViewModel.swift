//
//  SignInVCViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import Foundation
import UIKit
import FirebaseAuth

class SignInVCViewModel {
    var viewModel = AuthenticationViewModel()
    var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
   
    
}

