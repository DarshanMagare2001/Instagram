//
//  SearchVCCollectionViewCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class SearchVCCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var multiplePostIcon: UIImageView!
    var tapAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        multiplePostIcon.isHidden = true
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
    
    func configureCell(post:PostAllDataModel){
        DispatchQueue.main.async {
            if let url = post.postImageURLs?[0] {
                ImageLoader.loadImage(for: URL(string: url), into: self.img, withPlaceholder: UIImage(systemName: "person.fill"))
            }
            if let postCount = post.postImageURLs?.count {
                self.multiplePostIcon.isHidden = (postCount > 1 ? false : true)
            }
        }
    }
    
}
