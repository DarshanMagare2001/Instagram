//
//  SearchVCCollectionViewCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class SearchVCCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    var tapAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        tapAction?()
    }
    
}
