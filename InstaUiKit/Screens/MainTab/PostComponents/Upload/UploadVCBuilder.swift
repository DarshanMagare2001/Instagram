//
//  UploadVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

final class UploadVCBuilder {
    
    static var backButtonPressedClosure : (()->())?
    static var shareBtnPressedClosure : (()->())?
    
    static func build(img:[UIImage]) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let uploadVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
        uploadVC.img = img
        uploadVC.navigationItem.hidesBackButton = true
        uploadVC.navigationItem.title = "Upload"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        uploadVC.navigationItem.leftBarButtonItem = backButton
        
        let shareBtn = UIBarButtonItem(title:"Share", style: .plain, target: self, action: #selector(shareBtnPressed))
        shareBtn.tintColor = UIColor(named: "GlobalBlue")
        uploadVC.navigationItem.rightBarButtonItem = shareBtn
        
        UploadVCBuilder.backButtonPressedClosure = { [weak uploadVC ] in
            uploadVC?.backButtonPressed()
        }
        
        UploadVCBuilder.shareBtnPressedClosure = { [weak uploadVC ] in
            uploadVC?.shareBtnPressed()
        }
        
        return uploadVC
    }
    
    @objc static func backButtonPressed() {
        backButtonPressedClosure?()
    }
    
    @objc static func shareBtnPressed() {
        shareBtnPressedClosure?()
    }
    
}
