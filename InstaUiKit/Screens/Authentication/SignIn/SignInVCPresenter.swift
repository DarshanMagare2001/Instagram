//
//  SignInVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

protocol SignInVCPresenterProtocol {
    
    func viewDidload()
    func fetchCDUsers()
    func showSwitchAccountVC()
    func goToSignUpVC()
    func signIn(emailTxtFld:String? , passwordTxtFld:String? , view : UIViewController)
    
    typealias Input = (
        email : Driver<String>,
        password : Driver<String>,
        login:Driver<Void>
    )
    
    typealias Output = (
        enableLogin : Driver<Bool>,()
    )
    
    typealias Producer = (SignInVCPresenterProtocol.Input) -> SignInVCPresenterProtocol
    
    var input : Input { get }
    var output : Output { get }
    
}

class SignInVCPresenter {
    
    weak var view : SignInVCProtocol?
    var interactor : SignInVCInteractorProtocol
    var router : SignInVCRouterProtocol
    var input:Input
    var output:Output
    var coreDataUsers = [CDUsersModel]()
    
    init(view:SignInVCProtocol,interactor:SignInVCInteractor,router:SignInVCRouter,input:Input){
        self.view = view
        self.interactor = interactor
        self.router = router
        self.input = input
        self.output = SignInVCPresenter.output(input: input)
    }
    
}

extension SignInVCPresenter : SignInVCPresenterProtocol {
    
    func goToSignUpVC() {
        router.goToSignUpVC()
    }
    
    func signIn(emailTxtFld: String?, passwordTxtFld: String?, view : UIViewController) {
        guard let emailTxtFld = emailTxtFld, let passwordTxtFld = passwordTxtFld else {
            return
        }
        interactor.login(emailTxtFld: emailTxtFld, passwordTxtFld: passwordTxtFld) { result in
            switch result {
            case .success(let bool):
                print(bool)
                self.interactor.saveFCMTokenOfCurrentUser { _ in
                    self.interactor.saveCurrentUserToCoreData(coreDataUsers: self.coreDataUsers, email: emailTxtFld, password: passwordTxtFld, view: view) { bool in
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
                    print("Sign In error: \(signInError.localizedDescription)")
                    MessageLoader.shared.hideLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        Alert.shared.alertOk(title: "Error!", message: error.localizedDescription, presentingViewController: view){ _ in}
                    }
                }
            }
        }
    }
    
    
    func showSwitchAccountVC() {
        router.showSwitchAccountVC()
    }
    
    func viewDidload(){
        fetchCDUsers()
        view?.updateTxtFlds()
        view?.setUpBinding()
    }
    
    func fetchCDUsers() {
        Task{
            let coreDataUsers = await interactor.fetchCoreDataUsers()
            self.coreDataUsers = coreDataUsers
        }
    }
    
}

private extension SignInVCPresenter {
    
    static func output(input:Input) -> Output {
        let enableLoginDriver =  Driver.combineLatest(input.email.map{( $0.isEmailValid() )},
                                                      input.password.map{( !$0.isEmpty && $0.isPasswordValid() )}).map{( $0 && $1 )}
        return (
            enableLogin:enableLoginDriver,()
        )
    }
    
}
