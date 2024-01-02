//
//  SearchVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class SearchVCBuilder {
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchVC") as!SearchVC
        let interactor = SearchVCInteractor()
        let router = SearchVCRouter(viewController: searchVC)
        let presenter = SearchVCPresenter(view: searchVC, interactor: interactor, router: router)
        searchVC.presenter = presenter
        searchVC.title = "Search"
        return factory(searchVC)
    }
}
