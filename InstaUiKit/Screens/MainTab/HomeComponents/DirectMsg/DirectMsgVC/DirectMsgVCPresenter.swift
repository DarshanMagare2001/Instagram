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
    func goToAddChatVC()
}

class DirectMsgVCPresenter {
    weak var view : DirectMsgVCProtocol?
    var interactor : DirectMsgVCInteractorProtocol
    var router : DirectMsgVCRouterProtocol
    init(view:DirectMsgVCProtocol,interactor:DirectMsgVCInteractorProtocol,router:DirectMsgVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
        NotificationCenterInternal.shared.addObserver(self, selector: #selector(handleNotification), name: .notification)
    }
    @objc func handleNotification() {
        DispatchQueue.global(qos: .background).async {
            self.interactor.fetchAllChatUsersAndCurrentUser { chatUsers, currentUser in
                print(chatUsers)
                DispatchQueue.main.async {
                    self.view?.configureTableView(chatUsers: chatUsers , currentUser : currentUser)
                    MessageLoader.shared.hideLoader()
                }
            }
        }
    }
}

extension DirectMsgVCPresenter : DirectMsgVCPresenterProtocol {
    
    func viewDidload() {
        view?.addDoneButtonToSearchBarKeyboard()
        fetchAllUniqueUsers()
        fetchAllChatUsersAndCurrentUser()
    }
    
    func fetchAllUniqueUsers() {
        interactor.fetchAllUniqueUsers()
    }
    
    func fetchAllChatUsersAndCurrentUser() {
        DispatchQueue.main.async {
            MessageLoader.shared.showLoader(withText: "Fetching Users")
        }
        DispatchQueue.global(qos: .background).async {
            self.interactor.fetchAllChatUsersAndCurrentUser { chatUsers, currentUser in
                print(chatUsers)
                DispatchQueue.main.async {
                    self.view?.configureTableView(chatUsers: chatUsers , currentUser : currentUser)
                    MessageLoader.shared.hideLoader()
                }
            }
        }
    }
    
    
    func goToAddChatVC(){
        let filteredUsers = interactor.allUniqueUsersArray.filter { newUser in
            return !(interactor.chatUsers?.contains { existingUser in
                return existingUser.uid == newUser.uid
            })!
        }
        router.goToAddChatVC(allUniqueUsersArray: filteredUsers)
    }
    
    
}


