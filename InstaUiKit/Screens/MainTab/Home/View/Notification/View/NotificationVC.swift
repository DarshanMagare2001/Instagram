//
//  NotificationVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/11/23.
//

import UIKit

class NotificationVC: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var currentUser : UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchCurrentUser(){
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    print(user)
                    self.currentUser = user
                    self.tableViewOutlet.reloadData()
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
}

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser?.followersRequest?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        if let cellData = currentUser , let uid = cellData.followersRequest?[indexPath.row] {
            FetchUserInfo.shared.fetchUserDataByUid(uid:uid) { result in
                switch result {
                case.success(let user):
                    if let user = user , let imgUrl = user.imageUrl , let name = user.name {
                        cell.name.text = name
                        ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        if let cellData = currentUser , let uid = cellData.followersRequest?[indexPath.row] {
            FetchUserInfo.shared.fetchUserDataByUid(uid:uid) { result in
                switch result {
                case.success(let user):
                    if let user = user {
                        destinationVC.user = user
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
