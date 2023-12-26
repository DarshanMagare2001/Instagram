//
//  HomeVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class HomeVCBuilder {
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as!HomeVC
        let userProfileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileImageView.contentMode = .scaleToFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.image = UIImage(named: "InstaLogo")
        let userProfileView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileView.addSubview(userProfileImageView)
        let userProfileItem = UIBarButtonItem(customView: userProfileView)
        homeVC.navigationItem.leftBarButtonItems = [userProfileItem]
        return factory(homeVC)
    }
}
