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
    var viewModel = ChatVCViewModel()
    var receiverUser: UserModel?
    var currentUid : String?
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
                        self.currentUid = currentUID
                        self.viewModel.startChat(senderUid: currentUID, receiverID: receiverUser.uid) { value in
                            if value {
                                self.tableViewOutlet.reloadData()
                                let indexPath = IndexPath(row: self.viewModel.messages.count - 1, section: 0)
                                self.tableViewOutlet.scrollToRow(at: indexPath, at: .bottom, animated: true)
                            }else{
                                self.tableViewOutlet.reloadData()
                                let indexPath = IndexPath(row: self.viewModel.messages.count - 1, section: 0)
                                self.tableViewOutlet.scrollToRow(at: indexPath, at: .bottom, animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImg.addGestureRecognizer(tapGesture)
        userImg.isUserInteractionEnabled = true
        
    }
    
    @objc func userImageTapped() {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        guard let receiverUser = receiverUser else { return }
        destinationVC.user = receiverUser
        destinationVC.isFollowAndBtnShow = false
        navigationController?.pushViewController(destinationVC, animated: true)
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
                            if let fmcToken = self.receiverUser?.fcmToken {
                                Data.shared.getData(key: "Name") {  (result: Result<String?, Error>) in
                                    switch result {
                                    case .success(let name):
                                        if let name = name {
                                            PushNotification.shared.sendPushNotification(to: fmcToken, title: name , body: messageText)
                                        }
                                    case.failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }
                        self.msgTxtFld.text = ""
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    // Function to send a message
    func sendMessage(senderID: String, receiverID: String, text: String) {
        let messageRef = viewModel.messagesRef?.childByAutoId()
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


extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgCell", for: indexPath) as! MsgCell
        cell.msgLbl.text = viewModel.messages[indexPath.row].text
        if let currentUid = currentUid {
            if viewModel.messages[indexPath.row].senderID == currentUid {
                cell.v2.isHidden = true
                cell.v1.isHidden = false
            }else{
                cell.v1.isHidden = true
                cell.v2.isHidden = false
            }
        }
        return cell
    }
}

