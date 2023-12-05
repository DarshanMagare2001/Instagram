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
    
    //    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //        let currMsg = arrMessage[indexPath.section]
    //        let arrDate = currMsg.strSentDate.split(separator: ",")
    //        let strHour = arrDate[2]
    //
    //        if currMsg.isSeen == true && currUser?.senderId == currMsg.senderId && indexPath.section == numberOfMsg - 1 {
    //            return 20
    //        }
    //        return 10
    //    }
    //
    //    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //
    //        let currMsg = arrMessage[indexPath.section]
    //        let arrDate = currMsg.strSentDate.split(separator: ",")
    //        let strHour = arrDate[2]
    //
    //        if currMsg.isSeen == true && currUser?.senderId == currMsg.senderId && indexPath.section == numberOfMsg - 1 {
    //            return NSAttributedString(
    //                string: "√Seen",
    //                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    //        }
    //        return nil
    //    }
    //
    //
    //
    //    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //        if arrMessage.count > 1 && indexPath.section > 0 {
    //
    //            let prevMsg = arrMessage[indexPath.section - 1]
    //            let currMsg = arrMessage[indexPath.section]
    //
    //            if currMsg.msgTimeStamp - prevMsg.msgTimeStamp > 60000 {
    //                return 40
    //            }
    //
    //        }
    //        return 0
    //    }
    //
    //    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //
    //        if arrMessage.count > 1 && indexPath.section > 0 {
    //
    //            let prevMsg = arrMessage[indexPath.section - 1]
    //            let currMsg = arrMessage[indexPath.section]
    //
    //            if currMsg.msgTimeStamp - prevMsg.msgTimeStamp > 60000 {
    //                return NSAttributedString(
    //                    string: Util.getStringFromDate(format: " dd/MM/YYYY HH:mm", date: Date(timeIntervalSince1970: currMsg.msgTimeStamp / 1000)),
    //                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    //            }
    //
    //        }
    //        return nil
    //
    //    }
    
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

