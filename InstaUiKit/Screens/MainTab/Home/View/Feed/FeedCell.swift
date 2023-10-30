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
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
