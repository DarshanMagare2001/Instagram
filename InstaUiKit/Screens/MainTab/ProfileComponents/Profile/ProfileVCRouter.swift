//
//  ProfileVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol ProfileVCRouterProtocol {
    func goToFeedViewVC(allPost:[PostAllDataModel])
    func goToProfilePresentedView(user:UserModel)
    func goToFollowersAndFollowingVC(user:UserModel)
    func goToEditProfileVC()
}

class ProfileVCRouter {
    var viewController : UIViewController
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension ProfileVCRouter : ProfileVCRouterProtocol {
    
    func goToFeedViewVC(allPost:[PostAllDataModel]){
        let feedViewVC = FeedViewVCBuilder.build(allPost:allPost)
        viewController.navigationController?.pushViewController(feedViewVC, animated: true)
    }
    
    func goToProfilePresentedView(user:UserModel){
        let storyboard = UIStoryboard.Common
        let profilePresentedView = storyboard.instantiateViewController(withIdentifier: "ProfilePresentedView") as! ProfilePresentedView
        profilePresentedView.user = user
        profilePresentedView.modalPresentationStyle = .overFullScreen
        viewController.present(profilePresentedView, animated: true, completion: nil)
    }
    
    func goToFollowersAndFollowingVC(user:UserModel){
        let storyboard = UIStoryboard.Common
        let followersAndFollowingVC = storyboard.instantiateViewController(withIdentifier: "FollowersAndFollowingVC") as! FollowersAndFollowingVC
        followersAndFollowingVC.user = user
        viewController.navigationController?.pushViewController(followersAndFollowingVC, animated: true)
    }
    
    func goToEditProfileVC(){
        let editProfileVC = EditProfileVCBuilder.build()
        viewController.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
}
