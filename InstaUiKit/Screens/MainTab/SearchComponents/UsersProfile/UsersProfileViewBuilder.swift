//
//  UsersProfileViewBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class UsersProfileViewBuilder {
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
        return usersProfileView
    }
}
