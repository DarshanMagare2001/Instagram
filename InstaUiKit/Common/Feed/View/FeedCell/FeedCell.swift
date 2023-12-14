//
//  FeedCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/07/23.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func feedCell(_ cell: FeedCell, didSelectPageAtIndex index: Int)
}

class FeedCell: UITableViewCell {
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postLocationLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var totalLikesCount: UILabel!
    @IBOutlet weak var likedByLbl: UILabel!
    @IBOutlet weak var steperControl: UIPageControl!
    var likeBtnTapped: (() -> Void)?
    var commentsBtnTapped: (() -> Void)?
    var doubleTapAction: (() -> Void)?
    var isLiked: Bool = false
    weak var delegate: FeedCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        tapGesture.numberOfTapsRequired = 2
        postImg.addGestureRecognizer(tapGesture)
        postImg.isUserInteractionEnabled = true
        postImg.clipsToBounds = true
    }
    
    @objc func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        doubleTapAction?()
        guard let gestureView = gesture.view, let postImg = gestureView as? UIImageView else { return }
        
        let size = min(postImg.frame.size.width, postImg.frame.size.height) / 3
        let heart = UIImageView(image: UIImage(systemName: "heart.fill"))
        heart.frame = CGRect(x: (postImg.frame.size.width - size) / 2,
                             y: (postImg.frame.size.height - size) / 2,
                             width: size,
                             height: size)
        heart.tintColor = .red
        postImg.addSubview(heart)
        
        DispatchQueue.main.asyncAfter(deadline:.now()+0.2) { [weak self] in
            UIView.animate(withDuration: 0.5, animations: {
                heart.alpha = 0
            }, completion: { done in
                if done {
                    heart.removeFromSuperview()
                }
            })
        }
        
    }
    
    
    @IBAction func stepperControlPressed(_ sender: UIPageControl) {
        delegate?.feedCell(self, didSelectPageAtIndex: sender.currentPage)
    }
    
    @IBAction func likeBtnPressed(_ sender: UIButton) {
        likeBtnTapped?()
    }
    
    @IBAction func commentBtnPressed(_ sender: UIButton) {
        commentsBtnTapped?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
