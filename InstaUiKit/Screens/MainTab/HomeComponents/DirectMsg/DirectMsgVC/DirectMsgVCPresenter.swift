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
    }
}

extension DirectMsgVCPresenter : DirectMsgVCPresenterProtocol {
   
    func viewDidload() {
        view?.addDoneButtonToSearchBarKeyboard()
        fetchAllUniqueUsers()
        fetchAllChatUsersAndCurrentUser()
    }
    
    func fetchAllUniqueUsers() {
//        interactor.fetchUniqueUsers{ result in
//            switch result {
//            case.success(let data):
//                if let data = data {
//                    self.allUniqueUsersArray = data
//                }
//            case.failure(let error):
//                print(error)
//            }
//        }
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
//        let filteredUsers = self.allUniqueUsersArray.filter { newUser in
//            return !(self.chatUsers.contains { existingUser in
//                return existingUser.uid == newUser.uid
//            })
//        }
//        router.goToAddChatVC(allUniqueUsersArray: filteredUsers)
    }
    
    
}


