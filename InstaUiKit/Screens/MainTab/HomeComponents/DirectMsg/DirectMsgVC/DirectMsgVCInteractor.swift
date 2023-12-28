//
//  DirectMsgVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol DirectMsgVCInteractorProtocol {
    func fetchChatUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void ) 
}

class DirectMsgVCInteractor {
    let dispatchGroup = DispatchGroup()
}

extension DirectMsgVCInteractor : DirectMsgVCInteractorProtocol {
    
    func fetchChatUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void ) {
        var chatUsers = [UserModel]()
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data , let chatUserList = data.usersChatList {
                    for uid in chatUserList {
                        self.dispatchGroup.enter()
                        FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                            self.dispatchGroup.leave()
                            switch result {
                            case.success(let userData):
                                if let userData = userData {
                                    chatUsers.append(userData)
                                }
                            case.failure(let error):
                                print(error)
                            }
                        }
                    }
                    self.dispatchGroup.notify(queue: .main) {
                        completion(.success(chatUsers))
                    }
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
}
