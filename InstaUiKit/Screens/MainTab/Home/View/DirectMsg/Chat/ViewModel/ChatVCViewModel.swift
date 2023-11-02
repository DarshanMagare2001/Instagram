//
//  ChatVCViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import Foundation
import Firebase

class ChatVCViewModel {
    var chatRoomID: String?
    var messagesRef: DatabaseReference?
    var messages: [Message] = []
    
    func startChat(senderUid : String? , receiverID: String? ,completionHandler : @escaping(Bool) -> Void){
        if let senderUid = senderUid , let receiverID = receiverID {
            // Generate a chat room ID using sender and receiver's UIDs
            chatRoomID = generateChatRoomID(senderID: senderUid, receiverID: receiverID)
            messagesRef = Database.database().reference().child("chats").child(self.chatRoomID ?? "").child("messages")
            // Observe new messages
            self.messagesRef?.observe(.childAdded, with: { snapshot in
                if let messageData = snapshot.value as? [String: Any],
                   let senderID = messageData["senderID"] as? String,
                   let receiverID = messageData["receiverID"] as? String,
                   let text = messageData["text"] as? String,
                   let timestamp = messageData["timestamp"] as? Double {
                    let message = Message(senderID: senderID, receiverID: receiverID, text: text, timestamp: timestamp)
                    self.messages.append(message)
                    completionHandler(true)
                }
            })
        }
    }
    // Function to generate a chat room ID
    func generateChatRoomID(senderID: String, receiverID: String) -> String {
        // Sort sender and receiver IDs and concatenate them
        let sortedIDs = [senderID, receiverID].sorted()
        return sortedIDs.joined(separator: "_")
    }
    
}
