//
//  FollowingCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class FollowingCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    var followBtnTapped: (() -> Void)?
    @IBAction func followBtnPressed(_ sender: UIButton) {
        followBtnTapped?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(user:UserModel?,currentUser:UserModel?){
        if let name = user?.name , let userName = user?.username , let imgUrl = user?.imageUrl ,let uid = user?.uid {
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                self.nameLbl.text = name
                self.userNameLbl.text = userName
                if let user = currentUser, let followings = user.followings {
                    if followings.contains(uid) {
                        self.followBtn.setTitle("Following", for: .normal)
                        self.followBtn.setTitleColor(.black, for: .normal)
                        self.followBtn.backgroundColor = .white
                    } else {
                        self.followBtn.setTitle("Follow", for: .normal)
                        self.followBtn.setTitleColor(.white, for: .normal)
                        self.followBtn.backgroundColor = UIColor(named:"GlobalBlue")
                    }
                }
            }
        }
    }
    
}
