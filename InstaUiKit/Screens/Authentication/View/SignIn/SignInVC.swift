//
//  SignInVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import RxSwift
import RxCocoa

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
                Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
                    if let destinationVC = destinationVC {
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }
        }
    }

    
    @IBAction func switchAccountsBtnPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyBoard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(destinationVC, animated: true)
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
