//
//  SignInVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

protocol SignInVCPresenterProtocol {
    func viewDidload()
    func showSwitchAccountVC()
    func signIn(emailTxtFld:String? , passwordTxtFld:String? , view : UIViewController)
}

class SignInVCPresenter {
    weak var view : SignInVCProtocol?
    var interactor : SignInVCInteractor
    var router : SignInVCRouter
    var coreDataUsers = [CDUsersModel]()
    init(view:SignInVCProtocol,interactor:SignInVCInteractor,router:SignInVCRouter){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension SignInVCPresenter : SignInVCPresenterProtocol {
    
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
        router.showSwitchAccountVC(coreDataUsers: coreDataUsers)
    }
    
    func viewDidload() {
        Task{
            let coreDataUsers = await interactor.fetchCoreDataUsers()
            self.coreDataUsers = coreDataUsers
        }
    }
    
}
