//
//  SignUpVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SwiftUI
import FirebaseAuth

class SignUpVC: UIViewController {
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    var isPasswordShow = false
    var viewModel : SignUpVCViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SignUpVCViewModel(presentingViewController: self)
        updateTxtFlds()
    }
    
    @IBAction func forgetPasswordBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        viewModel.signUp(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text) { value in
            if value {
                if let uid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) {
                    FetchUserInfo.shared.getFCMToken { fcmToken in
                        print(fcmToken)
                        if let fcmToken = fcmToken {
                            StoreUserInfo.shared.saveUsersFMCTokenAndUidToFirebase(uid: uid, fcmToken: fcmToken) { result in
                                switch result {
                                case .success(let success):
                                    print(success)
                                    self.saveUserToCoreData(uid:uid)
                                case .failure(let failure):
                                    print(failure)
                                    self.saveUserToCoreData(uid:uid)
                                }
                            }
                        }
                    }
                }
            }else{
                MessageLoader.shared.hideLoader()
            }
        }
    }
    
    
    @IBAction func logInWithFaceBookBtnPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func passwordHideShowBtnPressed(_ sender: UIButton) {
        isPasswordShow.toggle()
        if isPasswordShow {
            let image = UIImage(systemName: "eye")
            passwordHideShowBtn.setImage(image, for: .normal)
        }else{
            let image = UIImage(systemName: "eye.slash")
            passwordHideShowBtn.setImage(image, for: .normal)
        }
        passwordTxtFld.isSecureTextEntry.toggle()
    }
    
    func updateTxtFlds(){
        emailTxtFld.placeholder = "Enter email"
        passwordTxtFld.placeholder = "Enter password"
    }
    
    func saveUserToCoreData(uid:String){
        DispatchQueue.main.async {
            MessageLoader.shared.hideLoader()
            Alert.shared.alertYesNo(title: "Save User!", message: "Do you want to save user?.", presentingViewController: self) { _ in
                print("Yes")
                if let email = self.emailTxtFld.text , let password = self.passwordTxtFld.text {
                    CDUserManager.shared.createUser(user: CDUsersModel(id: UUID(), email: email, password: password, uid: uid)) { _ in
                        self.gotoMainTab()
                    }
                }
            } noHandler: { _ in
                print("No")
                self.gotoMainTab()
            }
        }
    }
    
    func gotoMainTab(){
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
}
