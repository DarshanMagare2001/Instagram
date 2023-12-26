//
//  SignInVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

protocol SignInVCProtocol : class {
    
}

class SignInVC: UIViewController, passUserBack {
    
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    var isPasswordShow = false
    var viewModel: SignInVCViewModel!
    var coreDataUsers = [CDUsersModel]()
    
    var presenter : SignInVCPresenterProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
        viewModel = SignInVCViewModel(presentingViewController: self)
        updateTxtFlds()
        Task{
            await fetchCoreDataUsers()
        }
    }
    
    
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        viewModel.login(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text) { value in
            if value {
                if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
                    FetchUserData.shared.getFCMToken { fcmToken in
                        if let fcmToken = fcmToken {
                            StoreUserData.shared.saveUsersFMCTokenAndUidToFirebase(uid: uid, fcmToken: fcmToken) { result in
                                switch result {
                                case .success(let success):
                                    print(success)
                                    if self.coreDataUsers.contains(where: { $0.uid == uid }) {
                                        MessageLoader.shared.hideLoader()
                                        self.gotoMainTab()
                                    } else {
                                        self.viewModel.saveUserToCoreData(uid: uid, email: self.emailTxtFld.text, password: self.passwordTxtFld.text) {
                                            self.gotoMainTab()
                                        }
                                    }
                                case .failure(let failure):
                                    print(failure)
                                    if self.coreDataUsers.contains(where: { $0.uid == uid }) {
                                        MessageLoader.shared.hideLoader()
                                        self.gotoMainTab()
                                    } else {
                                        self.viewModel.saveUserToCoreData(uid: uid, email: self.emailTxtFld.text, password: self.passwordTxtFld.text) {
                                            self.gotoMainTab()
                                        }
                                    }
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
    
    @IBAction func switchAccountsBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.Authentication
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "SwitchAccountVC") as! SwitchAccountVC
        destinationVC.cdUser = coreDataUsers
        destinationVC.delegate = self
        self.present(destinationVC, animated: true, completion: nil)
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.Authentication, destinationVCIdentifier: "SignUpVC") { destinationVC in
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
    
    
    
    func gotoMainTab(){
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    func fetchCoreDataUsers() async {
        do{
            let users = try await CDUserManager.shared.readUser()
            if let users = users {
                self.coreDataUsers = users
            }
        }catch let error {
            print(error)
        }
    }
    
    func passUserBack(user: CDUsersModel) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.viewModel.login(emailTxtFld: user.email, passwordTxtFld: user.password) { value in
                if value {
                    if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
                        FetchUserData.shared.getFCMToken { fcmToken in
                            if let fcmToken = fcmToken {
                                StoreUserData.shared.saveUsersFMCTokenAndUidToFirebase(uid: uid, fcmToken: fcmToken) { result in
                                    switch result {
                                    case .success(let success):
                                        print(success)
                                        MessageLoader.shared.hideLoader()
                                        self.gotoMainTab()
                                    case .failure(let failure):
                                        print(failure)
                                        MessageLoader.shared.hideLoader()
                                        self.gotoMainTab()
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
    }
    
    func isUserDelete(delete: Bool) {
        Task{
            await fetchCoreDataUsers()
        }
    }
    
}

extension SignInVC : SignInVCProtocol {
    
}
