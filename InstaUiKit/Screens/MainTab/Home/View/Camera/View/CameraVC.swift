//
//  CameraVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 10/11/23.
//

import UIKit

class CameraVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
   
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
