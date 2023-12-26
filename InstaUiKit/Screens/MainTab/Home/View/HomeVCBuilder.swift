//
//  HomeVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class HomeVCBuilder {
    private var postActionClosureForDirectMsgBtnForHomeVC: (() -> Void)?
    private var postActionClosureForNotificationBtnForHomeVC: (() -> Void)?
    
    enum BarButtonTypeForHomeVC {
        case directMessage
        case notification
    }
    
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as!HomeVC
        homeVC.navigationItem.leftBarButtonItems = [configureInstaLogo()]
        return factory(homeVC)
    }
    
    private static func configureInstaLogo() -> UIBarButtonItem {
        let userProfileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileImageView.contentMode = .scaleToFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.image = UIImage(named: "InstaLogo")
        let userProfileView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileView.addSubview(userProfileImageView)
        let userProfileItem = UIBarButtonItem(customView: userProfileView)
        return userProfileItem
    }
    
}
