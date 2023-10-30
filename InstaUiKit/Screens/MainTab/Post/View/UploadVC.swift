//
//  UploadVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/10/23.
//

import UIKit

class UploadVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
