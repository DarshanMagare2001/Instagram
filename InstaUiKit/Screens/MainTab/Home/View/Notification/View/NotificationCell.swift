//
//  NotificationCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/12/23.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var acceptBtn: RoundedButton!
    @IBOutlet weak var rejectBtn: RoundedButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptBtnPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func rejectBtnPressed(_ sender: UIButton) {
        
    }
    

}
