//
//  DirectMsgVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit
import RxSwift
import RxCocoa


class DirectMsgVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var chatUsers = [UserModel]()
    var allUniqueUsersArray = [UserModel]()
    var currentUser : UserModel?
    var viewModel = DirectMsgViewModel()
    let disposeBag = DisposeBag()
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonToSearchBarKeyboard()
        fetchUsers(){ _ in
            self.updateTableView()
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                MessageLoader.shared.hideLoader()
            }
            if self.chatUsers.isEmpty {
                self.goToAddChatVC()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.title = "Chats"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        let addChatBtn = UIBarButtonItem(image: UIImage(systemName:"plus"), style: .plain, target: self, action: #selector(addChatBtnPressed))
        addChatBtn.tintColor = .black
        navigationItem.rightBarButtonItem = addChatBtn
        
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    self.currentUser = user
                    self.updateTableView()
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addChatBtnPressed() {
        goToAddChatVC()
    }
   
    func goToAddChatVC() {
        let storyboard = UIStoryboard.MainTab
        // Filter users whose uid is not in chatUsers
        let filteredUsers = allUniqueUsersArray.filter { newUser in
            return !chatUsers.contains { existingUser in
                return existingUser.uid == newUser.uid
            }
        }
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddChatVC") as! AddChatVC
        destinationVC.delegate = self
        destinationVC.allUniqueUsersArray = filteredUsers
        navigationController?.present(destinationVC, animated: true, completion: nil)
    }
    
    
    func fetchUsers(completion: @escaping (Bool) -> Void){
        MessageLoader.shared.showLoader(withText: "Fetching Users")
        
        dispatchGroup.enter()
        viewModel.fetchChatUsers { result in
            self.dispatchGroup.leave()
            switch result {
            case.success(let data):
                if let data = data {
                    self.chatUsers = data
                }
            case.failure(let error):
                print(error)
            }
        }
        
        dispatchGroup.enter()
        viewModel.fetchUniqueUsers { result in
            self.dispatchGroup.leave()
            switch result {
            case.success(let data):
                if let data = data {
                    self.allUniqueUsersArray = data
                }
            case.failure(let error):
                print(error)
            }
        }
        
        dispatchGroup.notify(queue: .main){
            completion(true)
        }
    }
    
    func addDoneButtonToSearchBarKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
    
}

extension DirectMsgVC : passChatUserBack {
    func passChatUserBack(user: UserModel?) {
        if let user = user {
            if let userUid = user.uid {
                MessageLoader.shared.showLoader(withText: "Adding Users")
                if let currentUser = currentUser , let  senderId = currentUser.uid , let receiverId = user.uid {
                    StoreUserData.shared.saveUsersChatList(senderId: senderId, receiverId: receiverId) { result in
                        switch result {
                        case.success():
                            self.viewModel.fetchChatUsers { result in
                                switch result {
                                case.success(let data):
                                    if let data = data {
                                        self.chatUsers = data
                                        self.updateTableView()
                                        MessageLoader.shared.hideLoader()
                                    }
                                case.failure(let error):
                                    print(error)
                                    MessageLoader.shared.hideLoader()
                                }
                            }
                        case.failure(let error):
                            print(error)
                            MessageLoader.shared.hideLoader()
                        }
                    }
                }
            }
        }
    }
}

extension DirectMsgVC {
    func updateTableView() {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        
        let filteredUsers = BehaviorRelay<[UserModel]>(value: chatUsers)
        filteredUsers
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "DirectMsgCell", cellType: DirectMsgCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                
                // Reset cell content to avoid reuse issues
                cell.userImg.image = nil
                cell.nameLbl.text = nil
                cell.userNameLbl.text = nil
                
                if let name = element.name,
                   let userName = element.username,
                   let imgUrl = element.imageUrl,
                   let receiverUserId = element.uid {
                    
                    ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                    cell.nameLbl.text = name
                    
                    cell.directMsgButtonTapped = { [weak self] in
                        self?.navigateToChatVC(with: element)
                    }
                    
                    DispatchQueue.main.async {
                        if let currentUser = self.currentUser , let currentUid = currentUser.uid , let notification = currentUser.usersChatNotification {
                            self.viewModel.observeLastTextMessage(currentUserId: currentUid, receiverUserId: receiverUserId) { textMsg, senderUid in
                                print(textMsg)
                                if let textMsg = textMsg, let senderUid = senderUid {
                                    cell.userNameLbl.text = "\(senderUid == currentUid ? "You: " : "\(notification.contains(receiverUserId) ? "🔵":"") ")\(textMsg)"
                                }
                            }
                        }
                    }
                    
                }
            }
                    .disposed(by: disposeBag)
        
        tableViewOutlet.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.removeItem(at: indexPath.row)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                let filteredData = self?.chatUsers.filter { user in
                    return query.isEmpty || (user.name?.lowercased().contains(query.lowercased()) == true)
                }
                filteredUsers.accept(filteredData ?? [])
            })
            .disposed(by: disposeBag)
    }
    
    func removeItem(at index: Int) {
        let alertController = UIAlertController(
            title: "Delete User",
            message: "Are you sure you want to delete this user?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteUser(at: index)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteUser(at index: Int) {
        guard index < chatUsers.count else {
            return
        }
        
        let userToDelete = chatUsers[index].uid
        MessageLoader.shared.showLoader(withText: "Removing User")
        
        viewModel.removeUserFromChatlistOfSender(receiverId: userToDelete) { [weak self] _ in
            self?.viewModel.fetchChatUsers { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        self?.chatUsers = data
                        self?.updateTableView()
                        MessageLoader.shared.hideLoader()
                    }
                case .failure(let error):
                    print(error)
                    MessageLoader.shared.hideLoader()
                }
            }
        }
        
        if let currentUser = currentUser , let  senderId = currentUser.uid , let receiverId = userToDelete {
            StoreUserData.shared.removeUsersChatNotifications(senderId: senderId, receiverId: receiverId) { _ in}
        }
        
    }
    
    private func navigateToChatVC(with user: UserModel) {
        let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            destinationVC.receiverUser = user
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}
