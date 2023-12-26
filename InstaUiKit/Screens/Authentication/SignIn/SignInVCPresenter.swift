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
}

class SignInVCPresenter {
    weak var view : SignInVCProtocol?
    var interactor : SignInVCInteractor
    var router : SignInVCRouter
    init(view:SignInVCProtocol,interactor:SignInVCInteractor,router:SignInVCRouter){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension SignInVCPresenter : SignInVCPresenterProtocol {
    
    func viewDidload() {
        print("viewDidload")
    }
    
}
