//
//  UsersProfileView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/11/23.
//

import UIKit

class UsersProfileView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
   
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
