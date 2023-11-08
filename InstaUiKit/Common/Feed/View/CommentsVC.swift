//
//  CommentsVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 08/11/23.
//

import UIKit

class CommentsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
