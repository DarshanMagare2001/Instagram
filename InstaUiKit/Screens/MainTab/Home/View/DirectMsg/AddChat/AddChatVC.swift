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
    var allUniqueUsersArray : [UserModel]?
    var delegate : passChatUserBack?
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AddChatVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUniqueUsersArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddChatVCCell", for: indexPath) as! AddChatVCCell
        guard let cellData = allUniqueUsersArray?[indexPath.row] else { return cell}
        guard let imgUrl = cellData.imageUrl,
              let name = cellData.name ,
              let userName = cellData.username else { return cell}
        ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        cell.nameLbl.text = name
        cell.userNameLbl.text = userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Alert.shared.alertYesNo(title: "Add Chat User", message: "Do you want to add user to chat section?.", presentingViewController: self) { _ in
            print("Yes")
            if let allUniqueUsersArray = self.allUniqueUsersArray {
                self.delegate?.passChatUserBack(user: self.allUniqueUsersArray?[indexPath.row])
            }
            self.dismiss(animated: true)
        } noHandler: { _ in
            print("No")
        }
    }
    
}
