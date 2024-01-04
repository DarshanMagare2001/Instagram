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
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var totalLikesCount: UILabel!
    @IBOutlet weak var likedByLbl: UILabel!
    @IBOutlet weak var steperControl: UIPageControl!
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    var likeBtnTapped: (() -> Void)?
    var commentsBtnTapped: (() -> Void)?
    var doubleTapAction: (() -> Void)?
    var steperControlPressed: ((Int) -> Void)?
    var viewModel = FeedCellViewModel()
    let disPatchGroup = DispatchGroup()
    var isLiked: Bool = false
    var postImageURLs = [String]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCollectionViewCell()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        tapGesture.numberOfTapsRequired = 2
        userImg2View.isHidden = false
        userImg3View.isHidden = false
        userImg4View.isHidden = false
        likedBysectionView.isHidden = false
        
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
    
    private func setUpCollectionViewCell() {
        let nib = UINib(nibName: "PostsCollectionViewCell", bundle: nil)
        postsCollectionView.register(nib, forCellWithReuseIdentifier: "PostsCollectionViewCell")
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        if let flowLayout = postsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
        postsCollectionView.isPagingEnabled = true
    }
    
    
    func configureCellData(post:PostAllDataModel?,view:UIViewController) {
        
        userImg1.image = nil
        userImg2.image = nil
        userImg3.image = nil
        userImg4.image = nil
        userName.text = nil
        postLocationLbl.text = nil
        postCaption.text = nil
        totalLikesCount.text = nil
        likedByLbl.text = nil
        
        guard let postUid = post?.uid ,
              let postName = post?.name ,
              let profileImgUrl = post?.profileImageUrl ,
              let postImageURLs = post?.postImageURLs,
              let postLocation = post?.location,
              let postCaption = post?.caption ,
              let postComments = post?.comments,
              let postUserName = post?.username,
              let postLikesCounts = post?.likesCount,
              let postLikedBy = post?.likedBy,
              let postPostDocumentID = post?.postDocumentID else { return }
        
        DispatchQueue.main.async {
            self.postImageURLs = postImageURLs
            self.postsCollectionView.reloadData()
        }
        
        steperControl.numberOfPages = post?.postImageURLs?.count ?? 0
        steperControl.currentPage = 0
        
        steperControlPressed = { [weak self] pageIndex in
            DispatchQueue.main.async { [weak self] in
                
            }
        }
        
        
        DispatchQueue.main.async { [weak self] in
            ImageLoader.loadImage(for: URL(string:profileImgUrl), into: (self?.userImg1)!, withPlaceholder: UIImage(systemName: "person.fill"))
            self?.userName.text = postName
            self?.postLocationLbl.text = postLocation
            self?.postCaption.text = postCaption
            self?.totalLikesCount.text = "\(postLikesCounts) Likes"
        }
        
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
                
                if (postLikedBy.contains(uid)){
                    self?.isLiked = true
                    let imageName = self!.isLiked ? "heart.fill" : "heart"
                    self?.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                    self?.likeBtn.tintColor = self!.isLiked ? .red : .black
                }else{
                    self?.isLiked = false
                    let imageName = self!.isLiked ? "heart.fill" : "heart"
                    self?.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                    self?.likeBtn.tintColor = self!.isLiked ? .red : .black
                }
                
                self?.doubleTapAction = { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.likePost(postPostDocumentID: postPostDocumentID, uid: uid, postUid: postUid, cell: self)
                }
                
                self?.likeBtnTapped = { [weak self] in
                    if ((self?.isLiked) != nil) {
                        self?.viewModel.unLikePost(postPostDocumentID: postPostDocumentID, uid: uid, cell: self!)
                    } else {
                        self?.viewModel.likePost(postPostDocumentID: postPostDocumentID, uid: uid, postUid: postUid, cell: self!)
                    }
                }
                
            }
            self?.disPatchGroup.leave()
        }
        
        
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            self?.commentsBtnTapped = { [weak self] in
                let storyboard = UIStoryboard.Common
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                destinationVC.allPost = post
                view.navigationController?.pushViewController(destinationVC, animated: true)
            }
            self?.disPatchGroup.leave()
        }
        
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            guard !postLikedBy.isEmpty else {
                self?.disPatchGroup.leave()
                return
            }
            
            let maxUsersToShow = min(3, postLikedBy.count)
            var imageView: UIImageView?  // Declare imageView as an optional variable
            
            for i in 0..<maxUsersToShow {
                let likedUser = postLikedBy[i]
                
                DispatchQueue.global(qos: .background).async { [weak self] in
                    FetchUserData.shared.fetchUserDataByUid(uid: likedUser) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let profileImgUrl = data.imageUrl, let name = data.name {
                                switch i {
                                case 0:
                                    DispatchQueue.main.async { [weak self] in
                                        self?.likedBysectionView.isHidden = false
                                        self?.userImg2View.isHidden = false
                                        imageView = (self?.userImg2)!
                                        self?.likedByLbl.text = "Liked by \(name) and \(Int(postLikedBy.count - 1)) others."
                                    }
                                case 1:
                                    DispatchQueue.main.async { [weak self] in
                                        self?.userImg3View.isHidden = false
                                        imageView = self?.userImg3 as? UIImageView
                                    }
                                case 2:
                                    DispatchQueue.main.async { [weak self] in
                                        self?.userImg4View.isHidden = false
                                        imageView = self?.userImg4 as? UIImageView
                                    }
                                default:
                                    return
                                }
                                
                                DispatchQueue.main.async { [weak self] in
                                    if let imageView = imageView {
                                        ImageLoader.loadImage(for: URL(string: profileImgUrl), into: imageView, withPlaceholder: UIImage(systemName: "person.fill"))
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                        
                        if i == maxUsersToShow - 1 {
                            self?.disPatchGroup.leave()
                        }
                    }
                }
            }
        }
        
        disPatchGroup.notify(queue: .main){}
    }
    
}

extension FeedCell : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostsCollectionViewCell", for: indexPath) as! PostsCollectionViewCell
        let profileImgUrl = postImageURLs[indexPath.row]
        cell.postImg.image = nil
        DispatchQueue.main.async {
            ImageLoader.loadImage(for: URL(string: profileImgUrl), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth, height: collectionView.bounds.height)
    }
    
}
