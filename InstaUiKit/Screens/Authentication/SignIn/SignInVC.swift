//
//  SignInVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import RxCocoa
import RxSwift

protocol SignInVCProtocol : class {
    func updateTxtFlds()
    func setupInputs()
    func setUpBinding()
}

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    @IBOutlet weak var logInBtn: RoundedButtonWithBorder!
    
    var isPasswordShow = false
    var presenter : SignInVCPresenterProtocol?
    var presenterProducer : SignInVCPresenterProtocol.Producer!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputs()
        presenter?.viewDidload()
    }
    
    
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        presenter?.signIn(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text, view: self)
    }
    
    @IBAction func switchAccountsBtnPressed(_ sender: UIButton) {
        presenter?.showSwitchAccountVC()
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        presenter?.goToSignUpVC()
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
    
    @IBAction func forgotPasswordBtnPressed(_ sender: UIButton) {
        
    }
    
    
}

extension SignInVC : SignInVCProtocol {
    
    func updateTxtFlds(){
        emailTxtFld.placeholder = "Enter email"
        passwordTxtFld.placeholder = "Enter password"
    }
    
    
    func setupInputs() {
        presenter = presenterProducer((
            email : emailTxtFld.rx.text.orEmpty.asDriver(),
            password : passwordTxtFld.rx.text.orEmpty.asDriver(),
            login:logInBtn.rx.tap.asDriver()
        ))
    }
    
    func setUpBinding(){
        presenter?.output.enableLogin.debug("Enable Login Driver" , trimOutput: false)
            .drive(logInBtn.rx.isEnabled)
            .disposed(by: bag)
    }
    
}
