//
//  SwitchAccountVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import UIKit

class SwitchAccountVC: UIViewController {
    var user : [CDUsersModel]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension SwitchAccountVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchAccountCell", for: indexPath) as! SwitchAccountCell
        if let data = user?[indexPath.row]{
            FetchUserInfo.shared.fetchUserDataByUid(uid: data.uid) { result in
                switch result {
                case.success(let user):
                    if let user = user , let imgUrl = user.imageUrl , let name = user.name , let userName = user.username {
                        DispatchQueue.main.async {
                            ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                            cell.name.text = name
                            cell.userName.text = userName
                        }
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
    
}
