//
//  PhotosCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/07/23.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
    }
}
