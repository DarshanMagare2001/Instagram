//
//  AddStoryVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

final class AddStoryVCBuilder {
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let addStoryVC = storyboard.instantiateViewController(withIdentifier: "AddStoryVC") as! AddStoryVC
        addStoryVC.navigationItem.hidesBackButton = true
        addStoryVC.title = "Story"
        return addStoryVC
    }
}
