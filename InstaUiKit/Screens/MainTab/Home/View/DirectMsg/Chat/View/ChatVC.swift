import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatVC: MessagesViewController {
    var currentUser: SenderType?
    var receiverUser: UserModel?
    var messages: [Message] = []
    var viewModel = ChatVCModel()
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let data):
                if let data = data, let currentUserId = data.uid, let displayName = data.name, let receiverId = self.receiverUser?.uid {
                    self.currentUser = Sender(senderId: currentUserId, displayName: displayName)
                    self.viewModel.observeMessages(currentUserId: currentUserId, receiverUserId: receiverId){ data in
                        if let data = data {
                            self.messages.append(data)
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(animated: true)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
       
    }
    
    func sendMessage(text: String) {
        guard let currentUser = currentUser, let receiverUserId = receiverUser?.uid else {
            return
        }
        
        let messageRef = viewModel.messagesRef.childByAutoId()
        let message = [
            "senderId": currentUser.senderId,
            "displayName": currentUser.displayName,
            "messageId": messageRef.key ?? "",
            "sentDate": Formatter.iso8601.string(from: Date()),
            "kind": "text",
            "text": text
        ]
        
        messageRef.setValue(message)
    }
}

extension ChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currentUser ?? Sender(senderId: "", displayName: "")
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

