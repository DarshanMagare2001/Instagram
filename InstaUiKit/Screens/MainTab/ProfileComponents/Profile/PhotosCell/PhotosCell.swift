//
//  PhotosCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/07/23.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var multiplePostIcon: UIImageView!
    var imagePressed : (()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        multiplePostIcon.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.addGestureRecognizer(tapGesture)
        img.isUserInteractionEnabled = true
    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        imagePressed?()
    }
    
    func configureCell(post:PostAllDataModel){
        if let imageURL = URL(string: post.postImageURLs?[0] ?? "") {
            ImageLoader.loadImage(for: imageURL, into:img, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        
        if let postCount = post.postImageURLs?.count {
            multiplePostIcon.isHidden = ( postCount > 1 ?  false : true )
        }
    }
    
}
