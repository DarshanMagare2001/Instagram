//
//  DirectMsgVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol DirectMsgVCPresenterProtocol {
    func viewDidload()
    func fetchAllChatUsers()
}

class DirectMsgVCPresenter {
    weak var view : DirectMsgVCProtocol?
    var interactor : DirectMsgVCInteractorProtocol
    var router : DirectMsgVCRouterProtocol
    init(view:DirectMsgVCProtocol,interactor:DirectMsgVCInteractorProtocol,router:DirectMsgVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension DirectMsgVCPresenter : DirectMsgVCPresenterProtocol {
    
    func viewDidload() {
        view?.addDoneButtonToSearchBarKeyboard()
        fetchAllChatUsers()
    }
    
    func fetchAllChatUsers(){
        DispatchQueue.global(qos: .background).async{ [weak self] in
            self?.interactor.fetchChatUsers { result in
                switch result {
                case.success(let data):
                    if let data = data {
                        print(data)
                        DispatchQueue.main.async { [weak self] in
                            self?.view?.configureTableView(chatUsers: data)
                        }
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
