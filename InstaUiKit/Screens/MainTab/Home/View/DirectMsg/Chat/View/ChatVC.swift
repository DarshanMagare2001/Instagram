//
//  ChatVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import UIKit

class ChatVC: UIViewController {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    @IBOutlet weak var msgTxtFld: UITextField!
    
    var user : UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            if let url = user.imageUrl {
                ImageLoader.loadImage(for: URL(string: url), into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            }
            nameLbl.text = user.name
        }
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnPressed(_ sender: UIButton) {
        
    }
    
}

extension ChatVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgCell", for: indexPath) as! MsgCell
        if (indexPath.row % 2) == 0 {
            cell.v1.isHidden = true
            cell.v2.isHidden = false
        }else{
            cell.v2.isHidden = true
            cell.v1.isHidden = false
        }
        return cell
    }
    
}
