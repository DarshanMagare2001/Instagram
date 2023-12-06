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
    var refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonToSearchBarKeyboard()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewOutlet.addSubview(refreshControl)
        Task {
            await fetchUsers(){ _ in
                self.updateTableView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @objc private func refresh() {
        self.refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                await self.fetchUsers() { _ in
                    self.updateTableView()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addChatBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddChatVC") as! AddChatVC
        destinationVC.delegate = self
        navigationController?.present(destinationVC, animated: true, completion: nil)
    }
    
    
    func fetchUsers(completion: @escaping (Bool) -> Void) async {
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
                    // Notify completion when all asynchronous calls are finished
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
            print(user)
            if let userUid = user.uid {
                CDChatUsersManager.shared.createUser(user: CDChatUserModel(id: UUID(), uid: userUid)) { _ in
                    Task {
                        await self.fetchUsers(){ _ in
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
        // Create a BehaviorRelay to hold the filtered user data
        let filteredUsers = BehaviorRelay<[UserModel]>(value: chatUsers)
        // Bind the filtered user data to the table view
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
        // Observe changes in the search bar text
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
                // Update the filteredUsers BehaviorRelay with the filtered data
                filteredUsers.accept(filteredData ?? [])
            })
            .disposed(by: disposeBag)
    }
}
