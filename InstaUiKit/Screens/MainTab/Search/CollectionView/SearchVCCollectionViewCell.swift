//
//  SearchVCCollectionViewCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class SearchVCCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
    }
}
