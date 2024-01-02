//
//  AddStoryCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import UIKit

class AddStoryCell: UICollectionViewCell {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var addStoryBtn: CircularButtonWithBorder!
    var addStoryBtnClosure : (()->())?
    @IBAction func addStoryBtnPressed(_ sender: Any) {
        addStoryBtnClosure?()
    }
    
    func configureCell(imgUrl:String){
        ImageLoader.loadImage(for: URL(string: imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
    }
}
