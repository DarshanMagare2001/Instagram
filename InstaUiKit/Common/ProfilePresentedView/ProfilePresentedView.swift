//
//  ProfilePresentedView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 13/12/23.
//

import UIKit

class ProfilePresentedView: UIViewController {
    @IBOutlet var mainView: UIView!
    
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

