//
//  SwitchAccountVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import UIKit

class SwitchAccountVC: UIViewController {
    var user = [CDUsersModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CDUserManager.shared.readUser { result in
            switch result {
            case.success(let users):
                if let users = users {
                    self.user = users
                }
            case.failure(let error):
                print(error)
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
        cell.name.text = user[indexPath.row].email
        cell.userName.text = user[indexPath.row].password
        return cell
    }
    
}
