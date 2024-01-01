//
//  ChatVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation

protocol ChatVCPresenterProtocol {
    func viewDidload()
}

class ChatVCPresenter {
    weak var view : ChatVCProtocol?
    var interactor : ChatVCInteractorProtocol
    var router : ChatVCRouterProtocol
    init(view:ChatVCProtocol,interactor:ChatVCInteractorProtocol,router:ChatVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension ChatVCPresenter : ChatVCPresenterProtocol {
    
    func viewDidload() {
        
    }
    
}
