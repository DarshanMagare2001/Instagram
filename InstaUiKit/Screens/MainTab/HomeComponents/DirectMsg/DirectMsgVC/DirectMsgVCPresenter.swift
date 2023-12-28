//
//  DirectMsgVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol DirectMsgVCPresenterProtocol {
    func viewDidload()
    func fetchAllChatUsersAndCurrentUser()
    func fetchAllUniqueUsers()
    var chatUsers : [UserModel] { get set }
    var allUniqueUsersArray: [UserModel] { get set }
    var currentUser : UserModel? { get set }
}

class DirectMsgVCPresenter {
    weak var view : DirectMsgVCProtocol?
    var interactor : DirectMsgVCInteractorProtocol
    var router : DirectMsgVCRouterProtocol
    var chatUsers = [UserModel]()
    var allUniqueUsersArray = [UserModel]()
    var currentUser : UserModel?
    var observeChat = [[String:String]]()
    let dispatchGroup = DispatchGroup()
    init(view:DirectMsgVCProtocol,interactor:DirectMsgVCInteractorProtocol,router:DirectMsgVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension DirectMsgVCPresenter : DirectMsgVCPresenterProtocol {
    
    func viewDidload() {
        view?.addDoneButtonToSearchBarKeyboard()
        fetchAllUniqueUsers()
        fetchAllChatUsersAndCurrentUser()
    }
    
    func fetchAllUniqueUsers() {
        interactor.fetchUniqueUsers{ result in
            switch result {
            case.success(let data):
                if let data = data {
                    self.allUniqueUsersArray = data
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func fetchAllChatUsersAndCurrentUser() {
        
        MessageLoader.shared.showLoader(withText: "Fetching Users")
        
        dispatchGroup.enter()
        self.interactor.fetchChatUsers { result in
            switch result {
            case.success(let data):
                if let data = data {
                    print(data)
                    self.chatUsers = data
                }
            case.failure(let error):
                print(error)
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    self.currentUser = user
                }
            case.failure(let error):
                print(error)
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if let currentUser = self?.currentUser {
                self?.view?.configureTableView(chatUsers: self?.chatUsers ?? [] , currentUser : currentUser)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                MessageLoader.shared.hideLoader()
            }
        }
        
    }
}


