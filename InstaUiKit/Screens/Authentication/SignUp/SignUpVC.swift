//
//  SignUpVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SwiftUI
import FirebaseAuth
import RxCocoa
import RxSwift


protocol SignUpVCProtocol : class {
    func updateTxtFlds()
    func setupInputs()
    func setUpBinding()
}

class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    @IBOutlet weak var signUpBtn: RoundedButtonWithBorder!
    
    var isPasswordShow = false
    var presenter : SignUpVCPresenterProtocol?
    var presenterProducer : SignUpVCPresenterProtocol.Producer!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputs()
        presenter?.viewDidload()
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        presenter?.signUp(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text, view: self)
    }
    
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
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
    
    
}

extension SignUpVC : SignUpVCProtocol {
    
    func updateTxtFlds(){
        emailTxtFld.placeholder = "Enter email"
        passwordTxtFld.placeholder = "Enter password"
    }
    
    func setupInputs() {
        presenter = presenterProducer((
            email : emailTxtFld.rx.text.orEmpty.asDriver(),
            password : passwordTxtFld.rx.text.orEmpty.asDriver(),
            login:signUpBtn.rx.tap.asDriver()
        ))
    }
    
    func setUpBinding(){
        presenter?.output.enableLogin.debug("Enable Login Driver" , trimOutput: false)
            .drive(signUpBtn.rx.isEnabled)
            .disposed(by: bag)
    }
    
}
