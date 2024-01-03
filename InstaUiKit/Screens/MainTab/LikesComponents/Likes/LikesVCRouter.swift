//
//  LikesVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol LikesVCRouterProtocol {
   func goToUsersProfileView(user:UserModel,isFollowAndMsgBtnShow:Bool)
}

class LikesVCRouter {
    var viewController : UIViewController
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension LikesVCRouter : LikesVCRouterProtocol {
    func goToUsersProfileView(user: UserModel, isFollowAndMsgBtnShow: Bool) {
        let usersProfileView = UsersProfileViewBuilder.build(user: user, isFollowAndMsgBtnShow: isFollowAndMsgBtnShow)
        viewController.navigationController?.pushViewController(usersProfileView, animated: true)
    }
}
