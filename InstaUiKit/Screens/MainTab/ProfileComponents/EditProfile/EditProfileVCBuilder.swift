//
//  EditProfileVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

final class EditProfileVCBuilder {
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        let interactor = EditProfileVCInteractor()
        let presenter = EditProfileVCPresenter(view: editProfileVC, interactor: interactor)
        editProfileVC.presenter = presenter
        editProfileVC.interactor = interactor
        return editProfileVC
    }
}
