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
    var viewModel = AuthenticationViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTxtFlds()
        
    }
    
    @IBAction func forgetPasswordBtnPressed(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        if emailTxtFld.text == "" || passwordTxtFld.text == "" {
            alert(title: "Warning!", message: "Please fill in all the required fields before proceeding.")
        }else{
            guard let email = emailTxtFld.text ,let password = passwordTxtFld.text else {return}
            viewModel.signUp(email: email, password: password) { error in
                if let error = error {
                    print(error.localizedDescription)
                    self.alert(title: "Error!", message: error.localizedDescription)
                }else{
                    print("Sign In Successfuly")
                    Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "MainTabVC") { destinationVC in
                        if let destinationVC = destinationVC {
                            self.navigationController?.pushViewController(destinationVC, animated: true)
                        }
                    }
                }
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
    
    func alert(title:String ,message : String){
        let alertController = UIAlertController(title:title, message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
