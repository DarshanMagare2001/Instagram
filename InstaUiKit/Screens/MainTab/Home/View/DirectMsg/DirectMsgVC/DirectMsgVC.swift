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
    let disposeBag = DisposeBag()
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonToSearchBarKeyboard()
        Task {
            await fetchUsers(){ _ in
                MessageLoader.shared.hideLoader()
                self.updateTableView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addChatBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddChatVC") as! AddChatVC
        destinationVC.delegate = self
        destinationVC.allUniqueUsersArray = allUniqueUsersArray
        navigationController?.present(destinationVC, animated: true, completion: nil)
    }
    
    
    
    func fetchUsers(completion: @escaping (Bool) -> Void) async {
        MessageLoader.shared.showLoader(withText: "Fetching Users")
        do {
            await fetchChatUsers { _ in }
            await fetchUniqueUsers { success in
                MessageLoader.shared.hideLoader()
                completion(success)
            }
        } catch {
            MessageLoader.shared.hideLoader()
            completion(false)
        }
    }
    
    func fetchUniqueUsers(completion:@escaping (Bool) -> Void){
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard let user = user, let following = user.followings else {
                    completion(false)
                    return
                }
                FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
                    switch result {
                    case .success(let data):
                        let uniqueUserUids = Set(following)
                        let newUsers = data.filter { user in
                            guard let userUid = user.uid else { return false }
                            return uniqueUserUids.contains(userUid) && !self.allUniqueUsersArray.contains(where: { $0.uid == user.uid })
                        }
                        self.allUniqueUsersArray.append(contentsOf: newUsers)
                        completion(true)
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
                
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    
    func fetchChatUsers(completion:@escaping (Bool) -> Void) async {
        do {
            let cdChatusers = try await CDChatUsersManager.shared.readUser()
            if let cdChatusers = cdChatusers {
                chatUsers.removeAll() // Clear the array before appending new users
                for user in cdChatusers {
                    dispatchGroup.enter()
                    await FetchUserInfo.shared.fetchUserDataByUid(uid: user.uid) { result in
                        self.dispatchGroup.leave()
                        switch result {
                        case .success(let userData):
                            print(userData)
                            if let userData = userData {
                                self.chatUsers.append(userData)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    completion(true)
                }
            } else {
                completion(false)
            }
        } catch {
            print(error)
            completion(false)
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
                CDChatUsersManager.shared.createUser(user: CDChatUserModel(id: UUID(), uid: userUid)) { _ in
                    Task {
                        await self.fetchChatUsers{ success in
                            MessageLoader.shared.hideLoader()
                            self.updateTableView()
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
                    .items(cellIdentifier: "DirectMsgCell", cellType: DirectMsgCell.self)) { (row, element, cell) in
                if let name = element.name , let userName = element.username , let imgUrl = element.imageUrl {
                    DispatchQueue.main.async {
                        ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        cell.nameLbl.text = name
                        cell.userNameLbl.text = userName
                        cell.directMsgButtonTapped = { [weak self] in
                            let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
                            let destinationVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                            destinationVC.receiverUser = element
                            self?.navigationController?.pushViewController(destinationVC, animated: true)
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
                // Filter the user data based on the search query
                let filteredData = self?.chatUsers.filter { user in
                    if query.isEmpty {
                        return true
                    } else {
                        return (user.name?.lowercased().contains(query.lowercased()) == true)
                    }
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
        chatUsers.remove(at: index)
        tableViewOutlet.reloadData()
    }
    
}
