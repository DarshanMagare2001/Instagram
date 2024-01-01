//
//  ChatVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation
import MessageKit
import Firebase

protocol ChatVCInteractorProtocol {
    func observeMessages(currentUserId: String?, receiverUserId: String? , completion: @escaping (Message?) -> Void)
    func sendMessage(text: String,receiverUser:UserModel?,completion:@escaping (String?) -> Void)
    var currentUser: SenderType? { get set }
    var currentUserModel: UserModel? { get set }
    var messages: [Message] { get set }
}

class ChatVCInteractor {
    var messagesRef: DatabaseReference!
    var currentUser: SenderType?
    var currentUserModel: UserModel?
    var messages: [Message] = []
}

extension ChatVCInteractor : ChatVCInteractorProtocol {
    
    func observeMessages(currentUserId: String?, receiverUserId: String? , completion: @escaping (Message?) -> Void) {
        if let currentUserId = currentUserId, let receiverUserId = receiverUserId {
            messagesRef = Database.database().reference().child("messages").child(chatPath(senderId: currentUserId, receiverId: receiverUserId))
        } else {
            // Handle the case where either currentUserId or receiverUserId is nil
            print("Error: currentUserId or receiverUserId is nil")
        }
        messagesRef.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let senderId = messageData["senderId"] as? String,
                  let displayName = messageData["displayName"] as? String,
                  let messageId = messageData["messageId"] as? String,
                  let sentDateString = messageData["sentDate"] as? String,
                  let sentDate = Formatter.iso8601.date(from: sentDateString),
                  let kindString = messageData["kind"] as? String else {
                      return
                  }
            
            let sender = Sender(senderId: senderId, displayName: displayName)
            let messageKind: MessageKind
            
            switch kindString {
            case "text":
                let text = messageData["text"] as? String ?? ""
                messageKind = .text(text)
                // Add more cases for other message types if needed
            default:
                return
            }
            
            let message = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: messageKind)
            DispatchQueue.main.async {
                completion(message)
            }
        }
    }
    
    func chatPath(senderId: String, receiverId: String) -> String {
        return senderId < receiverId ? "\(senderId)_\(receiverId)" : "\(receiverId)_\(senderId)"
    }
    
    func sendMessage(text: String,receiverUser:UserModel?,completion:@escaping (String?) -> Void){
        guard let currentUser = self.currentUser, let receiverUserId = receiverUser?.uid else {
            return
        }
        let messageRef = self.messagesRef.childByAutoId()
        let message = [
            "senderId": currentUser.senderId,
            "displayName": currentUser.displayName,
            "messageId": messageRef.key ?? "",
            "sentDate": Formatter.iso8601.string(from: Date()),
            "kind": "text",
            "text": text
        ]
        messageRef.setValue(message)
        completion(text)
    }
    
}
