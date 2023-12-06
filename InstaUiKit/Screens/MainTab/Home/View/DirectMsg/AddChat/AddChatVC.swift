//
//  AddChatVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 06/12/23.
//

import UIKit

protocol passChatUserBack {
    func passChatUserBack(user:UserModel?)
}

class AddChatVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewOutlet: UITableView!
    var allUniqueUsersArray = [UserModel]()
    var delegate : passChatUserBack?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers(){ _ in}
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
                        self.tableViewOutlet.reloadData()
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
    
    
}

extension AddChatVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUniqueUsersArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddChatVCCell", for: indexPath) as! AddChatVCCell
        let cellData = allUniqueUsersArray[indexPath.row]
        guard let imgUrl = cellData.imageUrl else { return cell}
        let name = cellData.name
        let userName = cellData.username
        ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        cell.nameLbl.text = name
        cell.userNameLbl.text = userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Alert.shared.alertYesNo(title: "Add Chat User", message: "Do you want to add user to chat section?.", presentingViewController: self) { _ in
            print("Yes")
            self.delegate?.passChatUserBack(user: self.allUniqueUsersArray[indexPath.row])
            self.dismiss(animated: true)
        } noHandler: { _ in
            print("No")
        }
    }
    
}
