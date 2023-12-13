//
//  ProfilePresentedView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 13/12/23.
//

import UIKit

class ProfilePresentedView: UIViewController {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurView()
    }
    
    func setBlurView() {
        let blurView = UIVisualEffectView()
        blurView.frame = view.frame
        blurView.effect = UIBlurEffect(style: .regular)
        mainView.addSubview(blurView)
    }
    
}

