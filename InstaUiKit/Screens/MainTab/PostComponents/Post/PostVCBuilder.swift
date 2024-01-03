//
//  PostVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class PostVCBuilder {
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let postVC = storyboard.instantiateViewController(withIdentifier: "PostVC") as!PostVC
        let router = PostVCRouter(viewController: postVC)
        let presenter = PostVCPresenter(view: postVC, router: router)
        postVC.presenter = presenter
        postVC.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = "Post"
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.sizeToFit()
        postVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
        return factory(postVC)
    }
}

