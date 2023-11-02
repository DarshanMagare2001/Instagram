//
//  ChatVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import UIKit
import Firebase

class ChatVC: UIViewController {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var msgTxtFld: UITextField!
    var receiverUser: UserModel?
    var chatRoomID: String?
    var messagesRef: DatabaseReference?
    var messages: [Message] = [] // Store chat messages here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let receiverUser = receiverUser {
            if let url = receiverUser.imageUrl {
                ImageLoader.loadImage(for: URL(string: url), into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            }
            nameLbl.text = receiverUser.name
            
            // Get the UID of the current user
            Data.shared.getData(key: "CurrentUserId") { (result: Result<String?, Error>) in
                switch result {
                case .success(let uid):
                    if let currentUID = uid {
                        // Generate a chat room ID using sender and receiver's UIDs
                        self.chatRoomID = self.generateChatRoomID(senderID: currentUID, receiverID: receiverUser.uid ?? "")
                        self.messagesRef = Database.database().reference().child("chats").child(self.chatRoomID ?? "").child("messages")
                        
                        // Observe new messages
                        self.messagesRef?.observe(.childAdded, with: { snapshot in
                            if let messageData = snapshot.value as? [String: Any],
                               let senderID = messageData["senderID"] as? String,
                               let receiverID = messageData["receiverID"] as? String,
                               let text = messageData["text"] as? String,
                               let timestamp = messageData["timestamp"] as? Double {
                                
                                let message = Message(senderID: senderID, receiverID: receiverID, text: text, timestamp: timestamp)
                                self.messages.append(message)
                                self.tableViewOutlet.reloadData()
                                // Scroll to the last message
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableViewOutlet.scrollToRow(at: indexPath, at: .bottom, animated: true)
                            }
                        })
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
        Data.shared.getData(key: "CurrentUserId") { (result: Result<String?, Error>) in
            switch result {
            case .success(let uid):
                if let uid = uid {
                    if let messageText = self.msgTxtFld.text, !messageText.isEmpty {
                        if let receiverID = self.receiverUser?.uid {
                            self.sendMessage(senderID: uid, receiverID: receiverID, text: messageText)
                        }
                        self.msgTxtFld.text = ""
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Function to generate a chat room ID
    func generateChatRoomID(senderID: String, receiverID: String) -> String {
        // Sort sender and receiver IDs and concatenate them
        let sortedIDs = [senderID, receiverID].sorted()
        return sortedIDs.joined(separator: "_")
    }
    
    // Function to send a message
    func sendMessage(senderID: String, receiverID: String, text: String) {
        let messageRef = messagesRef?.childByAutoId()
        let messageData: [String: Any] = [
            "senderID": senderID,
            "receiverID": receiverID,
            "text": text,
            "timestamp": ServerValue.timestamp()
        ]
        messageRef?.setValue(messageData) { (error, _) in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }

}

struct Message {
    let senderID: String
    let receiverID: String
    let text: String
    let timestamp: Double
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgCell", for: indexPath) as! MsgCell
        cell.msgLbl.text = messages[indexPath.row].text
        return cell
    }
}

