//
//  SearchVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation

protocol SearchVCPresenterProtocol {
    func viewDidload()
}

class SearchVCPresenter {
    weak var view : SearchVCProtocol?
    var interactor : SearchVCInteractorProtocol
    var router : SearchVCRouterProtocol
    init(view:SearchVCProtocol,interactor:SearchVCInteractorProtocol,router:SearchVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension SearchVCPresenter : SearchVCPresenterProtocol {
    
    func viewDidload() {
        
    }
    
}
