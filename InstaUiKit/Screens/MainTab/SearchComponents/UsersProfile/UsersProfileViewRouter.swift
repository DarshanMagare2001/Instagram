//
//  UsersProfileViewRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

protocol UsersProfileViewRouterProtocol {
    func goToFeedViewVC(allPost: [PostAllDataModel])
    func goToProfilePresentedView(user:UserModel)
    func goToFollowersAndFollowingVC(user:UserModel)
    func goToChatVC(user: UserModel)
}

class UsersProfileViewRouter {
    var viewController : UIViewController
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension UsersProfileViewRouter : UsersProfileViewRouterProtocol {
    
    func goToFeedViewVC(allPost: [PostAllDataModel]) {
        let feedViewVC = FeedViewVCBuilder.build(allPost: allPost)
        viewController.navigationController?.pushViewController(feedViewVC, animated: true)
    }
    
    func goToProfilePresentedView(user:UserModel) {
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ProfilePresentedView") as! ProfilePresentedView
        destinationVC.user = user
        destinationVC.modalPresentationStyle = .overFullScreen
        viewController.present(destinationVC, animated: true, completion: nil)
    }
    
    func goToFollowersAndFollowingVC(user:UserModel){
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FollowersAndFollowingVC") as! FollowersAndFollowingVC
        destinationVC.user = user
       viewController.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func goToChatVC(user: UserModel){
        let chatVC = ChatVCBuilder.build(user: user)
        viewController.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
