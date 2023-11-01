//
//  SearchVCTableViewCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class SearchVCTableViewCell: UITableViewCell {
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
