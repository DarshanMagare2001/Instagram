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
        return factory(homeVC)
    }
}
