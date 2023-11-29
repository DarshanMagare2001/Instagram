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
            cell.name.text = data.email
            cell.userName.text = data.password
        }
        return cell
    }
    
}
