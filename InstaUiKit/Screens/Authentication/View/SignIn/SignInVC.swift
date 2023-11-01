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
    var fcmToken : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel = SignInVCViewModel(presentingViewController: self)
        updateTxtFlds()
        Data.shared.getData(key: "FCMToken") { (result:Result<String?,Error>) in
            switch result {
            case .success(let fcmtoken):
                if let fcmtoken = fcmtoken {
                    print(fcmtoken)
                    self.fcmToken = fcmtoken
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        viewModel.login(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text) { value in
            if value {
                Data.shared.getData(key: "CurrentUserId") { (result:Result<String?,Error>) in
                    switch result {
                    case .success(let uid):
                        if let uid = uid {
                            if let fcmToken = self.fcmToken {
                                UserInfo.shared.saveUsersFMCTokenAndUid(uid: uid, fcmToken: fcmToken) { result in
                                    switch result {
                                    case .success(let success):
                                        print(success)
                                        DispatchQueue.main.async {
                                            LoaderVCViewModel.shared.hideLoader()
                                            Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
                                                if let destinationVC = destinationVC {
                                                    self.navigationController?.pushViewController(destinationVC, animated: true)
                                                }
                                            }
                                        }
                                    case .failure(let failure):
                                        print(failure)
                                        DispatchQueue.main.async {
                                            LoaderVCViewModel.shared.hideLoader()
                                            Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
                                                if let destinationVC = destinationVC {
                                                    self.navigationController?.pushViewController(destinationVC, animated: true)
                                                }
                                            }
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
    
}
