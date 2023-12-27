//
//  SignUpVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import UIKit

final class SignUpVCBuilder {
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.Authentication
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        signUpVC.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        signUpVC.navigationItem.leftBarButtonItem = backButton
        return signUpVC
    }
    
    @objc static func backButtonPressed(){
        
    }
    
}



