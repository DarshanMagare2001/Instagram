import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage


class ChatVC: MessagesViewController {
    var currentUser: SenderType?
    var currentUserModel: UserModel?
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
        let tapHideKeyboardGes = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let data):
                if let data = data, let currentUserId = data.uid, let displayName = data.name, let receiverId = self.receiverUser?.uid {
                    self.currentUserModel = data
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
    
    @objc func hideKeyboard() {
        view.endEditing(true)
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
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser?.senderId {
            return #colorLiteral(red: 0.09133880585, green: 0.7034819722, blue: 0.9843640924, alpha: 1)
        }
        return .lightGray.withAlphaComponent(0.4)
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8) // -> Them khoang trong giua cac tin nhan
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentUser?.senderId {
            if let imgUrl = currentUserModel?.imageUrl{
                avatarView.sd_setImage(with: URL(string: imgUrl))
            }
        } else {
            if let imgUrl = receiverUser?.imageUrl{
                avatarView.sd_setImage(with: URL(string: imgUrl))
            }
        }
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

