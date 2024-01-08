//
//  SignUpVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

protocol SignUpVCPresenterProtocol {
    
    func viewDidload()
    func signUp(emailTxtFld:String? , passwordTxtFld:String? , view : UIViewController)
    
    typealias Input = (
        email : Driver<String>,
        password : Driver<String>,
        login:Driver<Void>
    )
    
    typealias Output = (
        enableLogin : Driver<Bool>,()
    )
    
    typealias Producer = (SignUpVCPresenterProtocol.Input) -> SignUpVCPresenterProtocol
    
    var input : Input { get }
    var output : Output { get }
    
}

class SignUpVCPresenter {
    
    weak var view : SignUpVCProtocol?
    var interactor : SignUpVCInteractorProtocol
    var router : SignUpVCRouterProtocol
    var input:Input
    var output:Output
    
    init(view:SignUpVCProtocol,interactor:SignUpVCInteractorProtocol,router:SignUpVCRouterProtocol,input:Input){
        self.view = view
        self.interactor = interactor
        self.router = router
        self.input = input
        self.output = SignUpVCPresenter.output(input: input)
    }
    
}

extension SignUpVCPresenter : SignUpVCPresenterProtocol {
    
    func viewDidload() {
        view?.updateTxtFlds()
        view?.setUpBinding()
    }
    
    func signUp(emailTxtFld: String?, passwordTxtFld: String?, view: UIViewController) {
        guard let emailTxtFld = emailTxtFld, let passwordTxtFld = passwordTxtFld else {
            return
        }
        interactor.userSignUp(emailTxtFld: emailTxtFld, passwordTxtFld: passwordTxtFld) { result in
            switch result {
            case .success(let bool):
                print(bool)
                self.interactor.saveFCMTokenOfCurrentUser { _ in
                    self.interactor.saveCurrentUserToCoreData(email: emailTxtFld, password: passwordTxtFld, view: view) { bool in
                        if bool {
                            MessageLoader.shared.hideLoader()
                            self.router.goToMainTabVC()
                        }else{
                            MessageLoader.shared.hideLoader()
                            self.router.goToMainTabVC()
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .emailAndPasswordEmpty(let errorMessage):
                    print("Email and/or Password is empty: \(errorMessage)")
                    MessageLoader.shared.hideLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        Alert.shared.alertOk(title: "Warning!", message: "Please fill in all the required fields before proceeding.", presentingViewController: view){ _ in}
                    }
                case .signInError(let signInError):
                    print("Sign Up error: \(signInError.localizedDescription)")
                    MessageLoader.shared.hideLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        Alert.shared.alertOk(title: "Error!", message: error.localizedDescription, presentingViewController: view){ _ in}
                    }
                }
            }
        }
    }
    
}

private extension SignUpVCPresenter {
    
    static func output(input:Input) -> Output {
        let enableLoginDriver =  Driver.combineLatest(input.email.map{( $0.isEmailValid() )},
                                                      input.password.map{( !$0.isEmpty && $0.isPasswordValid() )}).map{( $0 && $1 )}
        return (
            enableLogin:enableLoginDriver,()
        )
    }
    
}
