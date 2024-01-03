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
        let interactor = PostVCInteractor()
        let router = PostVCRouter(viewController: postVC)
        let presenter = PostVCPresenter(view: postVC, interactor: interactor, router: router)
        postVC.presenter = presenter
        postVC.title = "Post"
        return factory(postVC)
    }
}

