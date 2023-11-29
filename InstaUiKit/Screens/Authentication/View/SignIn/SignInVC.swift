//
//  SignInVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

class SignInVC: UIViewController {
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    var isPasswordShow = false
    var viewModel: SignInVCViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel = SignInVCViewModel(presentingViewController: self)
        updateTxtFlds()
    }
    
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        viewModel.login(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text) { value in
            if value {
                Data.shared.getData(key: "CurrentUserId") { (result:Result<String?,Error>) in
                    switch result {
                    case .success(let uid):
                        if let uid = uid {
                            FetchUserInfo.shared.getFCMToken { fcmToken in
                                if let fcmToken = fcmToken {
                                    StoreUserInfo.shared.saveUsersFMCTokenAndUidToFirebase(uid: uid, fcmToken: fcmToken) { result in
                                        switch result {
                                        case .success(let success):
                                            print(success)
                                            self.saveUserToCoreData(uid: uid)
                                        case .failure(let failure):
                                            print(failure)
                                            self.saveUserToCoreData(uid: uid)
                                        }
                                    }
                                }
                            }
                        }
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }else{
                LoaderVCViewModel.shared.hideLoader()
            }
        }
    }
    
    @IBAction func switchAccountsBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.Main
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "SwitchAccountVC") as! SwitchAccountVC
        self.present(destinationVC, animated: true, completion: nil)
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.Main, destinationVCIdentifier: "SignUpVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
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
            LoaderVCViewModel.shared.hideLoader()
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
