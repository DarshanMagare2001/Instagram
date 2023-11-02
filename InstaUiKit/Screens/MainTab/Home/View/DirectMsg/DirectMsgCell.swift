//
//  DirectMsgCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class DirectMsgCell: UITableViewCell {
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var directMsgBtn: UIButton!
    // Define a closure to handle button tap action
    var directMsgButtonTapped: (() -> Void)?
    @IBAction func directMsgBtnPressed(_ sender: UIButton) {
        // Call the closure when the button is tapped
        directMsgButtonTapped?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
