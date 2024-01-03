//
//  LikesVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class LikesVCBuilder {
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let likesVC = storyboard.instantiateViewController(withIdentifier: "LikesVC") as!LikesVC
        let interactor = LikesVCInteractor()
        let router = LikesVCRouter(viewController: likesVC)
        let presenter = LikesVCPresenter(view: likesVC, interactor: interactor, router: router)
        likesVC.presenter = presenter
        likesVC.interactor = interactor
        likesVC.title = "Likes"
        return factory(likesVC)
    }
}


