//
//  SignUpVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation

protocol SignUpVCPresenterProtocol {
    func viewDidload()
}

class SignUpVCPresenter {
    
    weak var view : SignUpVCProtocol?
    var interactor : SignUpVCInteractorProtocol
    var router : SignUpVCRouterProtocol
    
    init(view:SignUpVCProtocol,interactor:SignUpVCInteractorProtocol,router:SignUpVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}

extension SignUpVCPresenter : SignUpVCPresenterProtocol {
    
    func viewDidload() {
        
    }
   
}
