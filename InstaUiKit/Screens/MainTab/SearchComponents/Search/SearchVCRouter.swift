//
//  SearchVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

protocol SearchVCRouterProtocol {
    func goToUsersProfileView(user: UserModel, isFollowAndMsgBtnShow: Bool)
    func goToFeedViewVC(allPost: [PostAllDataModel])
}

class SearchVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
    
}

extension SearchVCRouter : SearchVCRouterProtocol {
    
    func goToUsersProfileView(user: UserModel, isFollowAndMsgBtnShow: Bool){
        let usersProfileView = UsersProfileViewBuilder.build(user: user, isFollowAndMsgBtnShow: isFollowAndMsgBtnShow)
        viewController.navigationController?.pushViewController(usersProfileView, animated: true)
    }
    
    func goToFeedViewVC(allPost: [PostAllDataModel]){
        let feedViewVC = FeedViewVCBuilder.build(allPost:allPost)
        viewController.navigationController?.pushViewController(feedViewVC, animated: true)
    }
    
}
