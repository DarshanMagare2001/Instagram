//
//  DirectMsgVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import Firebase

protocol DirectMsgVCInteractorProtocol {
    func fetchChatUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void )
    func observeLastTextMessage(currentUserId: String?, receiverUserId: String?, completion: @escaping (String?, String?) -> Void)
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
    
    func observeLastTextMessage(currentUserId: String?, receiverUserId: String?, completion: @escaping (String?, String?) -> Void) {
        guard let currentUserId = currentUserId, let receiverUserId = receiverUserId else {
            print("Error: currentUserId or receiverUserId is nil")
            return
        }
        
        let chatPath = currentUserId < receiverUserId ? "\(currentUserId)_\(receiverUserId)" : "\(receiverUserId)_\(currentUserId)"
        
        let textMessagesRef = Database.database().reference().child("messages").child(chatPath)
        
        textMessagesRef.queryLimited(toLast: 1).observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let senderId = messageData["senderId"] as? String,
                  let kindString = messageData["kind"] as? String,
                  kindString == "text",
                  let text = messageData["text"] as? String else {
                      // Skip if not a valid text message
                      return
                  }
            
            DispatchQueue.main.async {
                completion(text, senderId)
            }
        }
    }
    
    
}
