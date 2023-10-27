//
//  SignUpVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

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
                LoaderVCViewModel.shared.hideLoader()
                Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
                    if let destinationVC = destinationVC {
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }else{
                LoaderVCViewModel.shared.hideLoader()
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
    
}
