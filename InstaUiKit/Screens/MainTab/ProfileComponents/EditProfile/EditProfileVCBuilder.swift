//
//  EditProfileVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

final class EditProfileVCBuilder {
    
    static var cancleBtnPressedClosure : (()->())?
    static var doneBtnPressedClosure : (()->())?
    
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        let interactor = EditProfileVCInteractor()
        let presenter = EditProfileVCPresenter(view: editProfileVC, interactor: interactor)
        editProfileVC.presenter = presenter
        editProfileVC.interactor = interactor
        editProfileVC.navigationItem.hidesBackButton = true
        editProfileVC.navigationItem.title = "Edit Profile"
        let cancleBtn = UIBarButtonItem(title:"Cancle", style: .plain, target: self, action: #selector(cancleBtnPressed))
        cancleBtn.tintColor = .black
        editProfileVC.navigationItem.leftBarButtonItem = cancleBtn
        
        let doneBtn = UIBarButtonItem(title:"Done", style: .plain, target: self, action: #selector(doneBtnPressed))
        doneBtn.tintColor = UIColor(named: "GlobalBlue")
        editProfileVC.navigationItem.rightBarButtonItem = doneBtn
        
        EditProfileVCBuilder.cancleBtnPressedClosure = {[ weak editProfileVC ] in
            editProfileVC?.cancleBtnPressed()
        }
        
        EditProfileVCBuilder.doneBtnPressedClosure = {[ weak editProfileVC ] in
            editProfileVC?.doneBtnPressed()
        }
        
        return editProfileVC
    }
    
    @objc static func cancleBtnPressed() {
        cancleBtnPressedClosure?()
    }
    
    @objc static func doneBtnPressed() {
        doneBtnPressedClosure?()
    }
    
}
