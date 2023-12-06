//
//  DirectMsgViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 06/12/23.
//

import Foundation

class DirectMsgViewModel {
    let dispatchGroup = DispatchGroup()
    
    func fetchUniqueUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void){
        var allUniqueUsersArray = [UserModel]()
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard let user = user, let following = user.followings else {return}
                FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
                    switch result {
                    case .success(let data):
                        let uniqueUserUids = Set(following)
                        let newUsers = data.filter { user in
                            guard let userUid = user.uid else { return false }
                            return uniqueUserUids.contains(userUid) && !allUniqueUsersArray.contains(where: { $0.uid == user.uid })
                        }
                        allUniqueUsersArray.append(contentsOf: newUsers)
                        completion(.success(allUniqueUsersArray))
                    case .failure(let error):
                        print(error)
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func fetchChatUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void ) {
        var chatUsers = [UserModel]()
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data , let chatUserList = data.usersChatList {
                    for uid in chatUserList {
                        self.dispatchGroup.enter()
                        FetchUserInfo.shared.fetchUserDataByUid(uid: uid) { result in
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
    
    func removeUserFromChatlistOdSender(receiverId : String? , completion : @escaping (Bool) -> Void ){
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data , let senderId = data.uid , let receiverId = receiverId {
                    StoreUserInfo.shared.removeUserFromChatUserListOfSender(senderId: senderId, receiverId: receiverId) { result in
                        switch result {
                        case.success():
                            completion(true)
                        case.failure(let error):
                            completion(false)
                        }
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
}
