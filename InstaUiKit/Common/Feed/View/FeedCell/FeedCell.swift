//
//  FeedCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/07/23.
//

import UIKit

class FeedCell: UITableViewCell {
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    @IBOutlet weak var userImg3: CircleImageView!
    @IBOutlet weak var userImg4: CircleImageView!
    @IBOutlet weak var userImg2View: UIView!
    @IBOutlet weak var userImg3View: UIView!
    @IBOutlet weak var userImg4View: UIView!
    @IBOutlet weak var likedBysectionView: UIView!
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
    var steperControlPressed: ((Int) -> Void)?
    var isLiked: Bool = false
    var allPost : [PostAllDataModel]?
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        tapGesture.numberOfTapsRequired = 2
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(_:)))
        rightSwipeGesture.direction = .right
        postImg.addGestureRecognizer(rightSwipeGesture)
        // Add left swipe gesture
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(_:)))
        leftSwipeGesture.direction = .left
        postImg.addGestureRecognizer(leftSwipeGesture)
        // Make sure user interaction is enabled
        postImg.isUserInteractionEnabled = true
        
        userImg2View.isHidden = true
        userImg3View.isHidden = true
        userImg4View.isHidden = true
        likedBysectionView.isHidden = true
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
    
    @objc func handleRightSwipe(_ gesture: UISwipeGestureRecognizer) {
        // Handle right swipe
        steperControl.currentPage = max(0, steperControl.currentPage - 1)
        steperControlPressed?(steperControl.currentPage)
    }
    
    @objc func handleLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
        // Handle left swipe
        steperControl.currentPage = min(steperControl.numberOfPages - 1, steperControl.currentPage + 1)
        steperControlPressed?(steperControl.currentPage)
    }
    
    @IBAction func stepperControlPressed(_ sender: UIPageControl) {
        steperControlPressed?(sender.currentPage)
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
    
    func updatePageControl(with count: Int) {
        steperControl.numberOfPages = count
    }
    
}

