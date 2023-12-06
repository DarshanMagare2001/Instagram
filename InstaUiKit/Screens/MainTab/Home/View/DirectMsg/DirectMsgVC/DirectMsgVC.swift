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
    var allUniqueUsersArray = [UserModel]()
    var refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonToSearchBarKeyboard()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewOutlet.addSubview(refreshControl)
        fetchUsers(){ _ in}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
  
    @objc private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchUsers(){ value in
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addChatBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddChatVC") as! AddChatVC
        navigationController?.present(destinationVC, animated: true, completion: nil)
    }

    
    func fetchUsers(completion:@escaping (Bool) -> Void){
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let user):
                guard let user = user, let following = user.followings else { return }

                FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
                    switch result {
                    case .success(let data):
                        let uniqueUserUids = Set(following)
                        let newUsers = data.filter { user in
                            guard let userUid = user.uid else { return false }
                            return uniqueUserUids.contains(userUid) && !self.allUniqueUsersArray.contains(where: { $0.uid == user.uid })
                        }
                        self.allUniqueUsersArray.append(contentsOf: newUsers)
                        self.updateTableView()
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
    
    
    func addDoneButtonToSearchBarKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
    
}

extension DirectMsgVC {
    func updateTableView() {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        // Create a BehaviorRelay to hold the filtered user data
        let filteredUsers = BehaviorRelay<[UserModel]>(value: allUniqueUsersArray)
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
                let filteredData = self?.allUniqueUsersArray.filter { user in
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
