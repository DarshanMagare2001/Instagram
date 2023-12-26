//
//  ProfileVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class ProfileVCBuilder {
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as!ProfileVC
        profileVC.title = "Profile"
        return factory(profileVC)
    }
}
