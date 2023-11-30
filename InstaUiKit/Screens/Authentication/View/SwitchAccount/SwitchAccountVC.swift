//
//  SwitchAccountVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import UIKit

class SwitchAccountVC: UIViewController {
    var viewModel = SwitchAccountViewModel()
    var cdUser : [CDUsersModel]?
    var user = [UserModel]()
    @IBOutlet weak var tableViewOutlet: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let cdUser = cdUser {
            viewModel.getUsers(cdUsers: cdUser) { data in
                DispatchQueue.main.async {
                    self.user = data
                    print(data)
                    self.tableViewOutlet.reloadData()
                }
            }
        }
    }
    
}

extension SwitchAccountVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchAccountCell", for: indexPath) as! SwitchAccountCell
        let data = user[indexPath.row]
        let imgUrl = data.imageUrl
        let name = data.name
        let userName = data.username
        DispatchQueue.main.async {
            ImageLoader.loadImage(for: URL(string:imgUrl ?? ""), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.name.text = name
            cell.userName.text = userName
        }
        return cell
    }
    
}
