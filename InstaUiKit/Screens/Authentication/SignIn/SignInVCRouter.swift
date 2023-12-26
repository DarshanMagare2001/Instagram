//
//  SignInVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

protocol SignInVCRouterProtocol {
    
}

class SignInVCRouter {
    var viewController: UIViewController
    init(view: UIViewController) {
        self.viewController = view
    }
}

extension SignInVCRouter : SignInVCRouterProtocol {
    
}
