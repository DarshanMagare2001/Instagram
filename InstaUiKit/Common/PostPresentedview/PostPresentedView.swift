//
//  PostPresentedView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 13/12/23.
//

import UIKit

class PostPresentedView: UIViewController {
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var mainView: RoundedViewWithBorder!
    @IBOutlet weak var userImg1: CircleImageView!
    @IBOutlet weak var userImg2: CircleImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var likeByLbl: UILabel!
    @IBOutlet weak var captionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(disMiss))
        baseView.isUserInteractionEnabled = true
        baseView.addGestureRecognizer(tapGesture)
    }
    
    @objc func disMiss(){
        dismiss(animated: true)
    }
    
    func setBlurView() {
        let blurView = UIVisualEffectView()
        blurView.frame = view.frame
        blurView.effect = UIBlurEffect(style: .regular)
        baseView.addSubview(blurView)
        baseView.addSubview(mainView)
    }
    
}
