//
//  UsersProfileViewPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation

protocol UsersProfileViewPresenterProtocol {
    func viewDidload()
}

class UsersProfileViewPresenter {
    weak var view : UsersProfileViewProtocol?
    var interactor : UsersProfileViewInteractorProtocol
    var router : UsersProfileViewRouterProtocol
    init(view:UsersProfileViewProtocol,interactor:UsersProfileViewInteractorProtocol,router:UsersProfileViewRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension UsersProfileViewPresenter : UsersProfileViewPresenterProtocol {
    func viewDidload() {
        print("viewDidload")
    }
}
