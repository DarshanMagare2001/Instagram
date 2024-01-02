//
//  UsersProfileViewBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class UsersProfileViewBuilder {
    
    static var backButtonPressedClosure : (()->())?
    
    static func build(user:UserModel , isFollowAndMsgBtnShow : Bool) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let usersProfileView = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        let interactor = UsersProfileViewInteractor()
        let router = UsersProfileViewRouter(viewController: usersProfileView)
        let presenter = UsersProfileViewPresenter(view: usersProfileView, interactor: interactor, router: router)
        usersProfileView.presenter = presenter
        usersProfileView.interactor = interactor
        usersProfileView.interactor?.user = user
        usersProfileView.interactor?.isFollowAndMsgBtnShow = isFollowAndMsgBtnShow
        usersProfileView.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        usersProfileView.navigationItem.leftBarButtonItem = backButton
        usersProfileView.navigationItem.title = user.name
        
        UsersProfileViewBuilder.backButtonPressedClosure = { [weak usersProfileView ] in
            usersProfileView?.backButtonPressed()
        }
        
        return usersProfileView
    }
    
    @objc static func backButtonPressed() {
        backButtonPressedClosure?()
    }
    
}
