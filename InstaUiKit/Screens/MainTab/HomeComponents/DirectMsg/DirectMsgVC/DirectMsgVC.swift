//
//  DirectMsgVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol DirectMsgVCProtocol :class {
    func addDoneButtonToSearchBarKeyboard()
    func configureTableView(chatUsers:[UserModel] , currentUser : UserModel )
}


class DirectMsgVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var presenter : DirectMsgVCPresenterProtocol?
    
    var allUniqueUsersArray = [UserModel]()
    var currentUser : UserModel?
    var viewModel = DirectMsgViewModel()
    let disposeBag = DisposeBag()
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    func addChatBtnPressed() {
        goToAddChatVC()
    }
    
    func goToAddChatVC() {
        let storyboard = UIStoryboard.MainTab
        // Filter users whose uid is not in chatUsers
        //        let filteredUsers = allUniqueUsersArray.filter { newUser in
        //            return !chatUsers.contains { existingUser in
        //                return existingUser.uid == newUser.uid
        //            }
        //        }
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddChatVC") as! AddChatVC
        destinationVC.delegate = self
        //        destinationVC.allUniqueUsersArray = filteredUsers
        navigationController?.present(destinationVC, animated: true, completion: nil)
    }
    
    
    func fetchUsers(completion: @escaping (Bool) -> Void){
        
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
    
    @objc func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
    
}

extension DirectMsgVC : DirectMsgVCProtocol {
    func addDoneButtonToSearchBarKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    func configureTableView(chatUsers:[UserModel] , currentUser : UserModel ) {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        
        let filteredUsers = BehaviorRelay<[UserModel]>(value: chatUsers)
        filteredUsers
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "DirectMsgCell", cellType: DirectMsgCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                cell.configureCell(currentUser: currentUser , element: element)
                cell.directMsgButtonTapped = { [weak self] in
                    self?.navigateToChatVC(with: element)
                }
                
            }.disposed(by: disposeBag)
        
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
                let filteredData = chatUsers.filter { user in
                    return query.isEmpty || (user.name?.lowercased().contains(query.lowercased()) == true)
                }
                filteredUsers.accept(filteredData ?? [])
            })
            .disposed(by: disposeBag)
    }
    
}


extension DirectMsgVC {
    
    func removeItem(at index: Int) {
        let alertController = UIAlertController(
            title: "Delete User",
            message: "Are you sure you want to delete this user?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            //            self?.deleteUser(at: index)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteUser(at index: Int , chatUsers : [UserModel] ) {
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
                        //                        self?.chatUsers = data
                        //                        self?.configureTableView()
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
                                        //                                        self.chatUsers = data
                                        //                                        self.configureTableView()
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


