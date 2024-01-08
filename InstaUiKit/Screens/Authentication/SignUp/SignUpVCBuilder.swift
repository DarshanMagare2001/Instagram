//
//  SignUpVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import UIKit

final class SignUpVCBuilder {
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.Authentication
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        let router = SignUpVCRouter(viewController: signUpVC)
        let interactor = SignUpVCInteractor()
        signUpVC.presenterProducer = {
            SignUpVCPresenter(view: signUpVC, interactor: interactor, router: router, input: $0)
        }
        signUpVC.navigationItem.hidesBackButton = true
        return signUpVC
    }
}



