//
//  SignInVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

protocol SignInVCRouterProtocol {
    func showSwitchAccountVC(coreDataUsers:[CDUsersModel])
    func goToMainTabVC()
    func goToSignUpVC()
}

class SignInVCRouter {
    var viewController: UIViewController
    init(view: UIViewController) {
        self.viewController = view
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

    
    func showSwitchAccountVC(coreDataUsers:[CDUsersModel]){
        let storyboard = UIStoryboard.Authentication
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "SwitchAccountVC") as! SwitchAccountVC
        destinationVC.cdUser = coreDataUsers
        //        destinationVC.delegate = self
        viewController.present(destinationVC, animated: true, completion: nil)
    }
    
}
