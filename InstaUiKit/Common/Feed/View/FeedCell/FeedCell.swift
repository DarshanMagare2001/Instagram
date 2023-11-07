//
//  FeedCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/07/23.
//

import UIKit

class FeedCell: UITableViewCell {
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postLocationLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    var likeBtnTapped: (() -> Void)?
    var isLiked: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func likeBtnPressed(_ sender: UIButton) {
        isLiked.toggle()
        let imageName = isLiked ? "heart.fill" : "heart"
        likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
        likeBtnTapped?()
    }

    
    @IBAction func commentBtnPressed(_ sender: UIButton) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
