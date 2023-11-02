//
//  MsgCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import UIKit

class MsgCell: UITableViewCell {
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var v2: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
