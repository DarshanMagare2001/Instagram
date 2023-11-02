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
}
