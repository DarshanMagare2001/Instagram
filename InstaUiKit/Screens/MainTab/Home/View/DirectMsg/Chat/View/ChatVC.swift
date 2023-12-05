import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatVC: MessagesViewController {
    var currentUser: SenderType?
    var receiverUser: UserModel?
    var messages: [Message] = []
    var messagesRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            // Handle the case where the user is not logged in
            return
        }
        
        currentUser = Sender(senderId: currentUserId, displayName: "Your Display Name")
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        guard let receiverUserId = receiverUser?.uid else {
            // Handle the case where the receiverUser is not set
            return
        }
        
        messagesRef = Database.database().reference().child("messages").child(chatPath(senderId: currentUserId, receiverId: receiverUserId))
        
        observeMessages()
    }
    
    func observeMessages() {
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
            self.messages.append(message)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    func sendMessage(text: String) {
        guard let currentUser = currentUser,
              let receiverUserId = receiverUser?.uid else {
                  return
              }
        
        let messageRef = messagesRef.childByAutoId()
        let message = ["senderId": currentUser.senderId,
                       "displayName": currentUser.displayName,
                       "messageId": messageRef.key,
                       "sentDate": Formatter.iso8601.string(from: Date()),
                       "kind": "text",
                       "text": text]
        
        messageRef.setValue(message)
    }
    
    func chatPath(senderId: String, receiverId: String) -> String {
        // Create a unique path for the chat based on the sender and receiver's uids
        return senderId < receiverId ? "\(senderId)_\(receiverId)" : "\(receiverId)_\(senderId)"
    }
}

extension ChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // Implement MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate methods
    // ...
    
    func currentSender() -> SenderType {
        return currentUser!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessage(text: text)
        inputBar.inputTextView.text = ""
    }
}

struct Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

