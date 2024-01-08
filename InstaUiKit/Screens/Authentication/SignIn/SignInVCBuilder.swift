//
//  SignInVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class SignInVCBuilder {
    static func build(factory: NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.Authentication
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        let interactor = SignInVCInteractor()
        let router = SignInVCRouter(view: signInVC, interactor: interactor)
        signInVC.presenterProducer = {
            SignInVCPresenter(view: signInVC, interactor: interactor, router: router, input: $0)
        }
        return factory(signInVC)
    }
}

