//
//  SignInVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

protocol SignInVCRouterProtocol : passUserBack{
    func showSwitchAccountVC(coreDataUsers: [CDUsersModel])
    func goToMainTabVC()
    func goToSignUpVC()
}

class SignInVCRouter {
    var viewController: UIViewController
    var interactor : SignInVCInteractor
    init(view: UIViewController , interactor : SignInVCInteractor ) {
        self.viewController = view
        self.interactor = interactor
    }
}

extension SignInVCRouter : SignInVCRouterProtocol {
    
    func goToSignUpVC() {
        let signUpVC = SignUpVCBuilder.build()
        self.viewController.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func goToMainTabVC(){
        let subModules = (
            home: HomeVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            search: SearchVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            post: PostVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            likes: LikesVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            profile: ProfileVCBuilder.build(factory: NavigationFactory.build(rootView:))
        )
        let mainTabVC = MainTabVCBuilder.build(subModules: subModules)
        // Access the window from the SceneDelegate
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = mainTabVC
            window.makeKeyAndVisible()
        }
    }
    
    
    func showSwitchAccountVC(coreDataUsers: [CDUsersModel]){
        let storyboard = UIStoryboard.Authentication
        let switchAccountVC = storyboard.instantiateViewController(withIdentifier: "SwitchAccountVC") as! SwitchAccountVC
        switchAccountVC.cdUser = coreDataUsers
        switchAccountVC.delegate = self
        viewController.present(switchAccountVC, animated: true, completion: nil)
    }
    
    func passUserBack(user: CDUsersModel) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.interactor.login(emailTxtFld: user.email, passwordTxtFld: user.password) { result in
                switch result {
                case .success(let bool):
                    print(bool)
                    self.interactor.saveFCMTokenOfCurrentUser { _ in
                        MessageLoader.shared.hideLoader()
                        self.goToMainTabVC()
                    }
                case .failure(let error):
                    switch error {
                    case .emailAndPasswordEmpty(let errorMessage):
                        print("Email and/or Password is empty: \(errorMessage)")
                        MessageLoader.shared.hideLoader()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            Alert.shared.alertOk(title: "Warning!", message: "Please fill in all the required fields before proceeding.", presentingViewController: self.viewController){ _ in}
                        }
                    case .signInError(let signInError):
                        print("Sign In error: \(signInError.localizedDescription)")
                        MessageLoader.shared.hideLoader()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            Alert.shared.alertOk(title: "Error!", message: error.localizedDescription, presentingViewController: self.viewController){ _ in}
                        }
                    }
                }
            }
        }
    }
    
}

