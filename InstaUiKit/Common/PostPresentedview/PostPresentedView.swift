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
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var likeByLbl: UILabel!
    @IBOutlet weak var captionLbl: UILabel!
    
    var post : PostAllDataModel?
    
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
        updateView()
    }
    
    func updateView(){
        if let post = post ,
           let profileImgUrl = post.profileImageUrl ,
           let postImgUrl = post.postImageURL,
           let name = post.name ,
           let location = post.location ,
           let caption = post.caption ,
           let likedBy = post.likedBy
        {
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: profileImgUrl), into: self.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                ImageLoader.loadImage(for: URL(string: profileImgUrl), into: self.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                ImageLoader.loadImage(for: URL(string: postImgUrl), into: self.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                self.nameLbl.text = name
                self.locationLbl.text = location
                self.captionLbl.text = caption
            }
        }
    }
    
}