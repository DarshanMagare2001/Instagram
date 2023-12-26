//
//  FeedViewVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/11/23.
//

import UIKit
import FirebaseAuth

class FeedViewVC: UIViewController {
    @IBOutlet weak var postTableViewOutlet: UITableView!
    var viewModel = FeedViewModel()
    var allPost : [PostAllDataModel]?
    var uid : String?
    let disPatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        postTableViewOutlet.register(nib, forCellReuseIdentifier: "FeedCell")
        if let currentUid = Auth.auth().currentUser?.uid {
            uid = currentUid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
        navigationItem.title = "All Posts"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        postTableViewOutlet.reloadData()
    }
    
    @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
}

extension FeedViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = allPost?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        if let post = allPost?[indexPath.row] {
            
            cell.userImg1.image = nil
            cell.userImg2.image = nil
            cell.userImg3.image = nil
            cell.userImg4.image = nil
            cell.userName.text = nil
            cell.postImg.image = nil
            cell.postLocationLbl.text = nil
            cell.postCaption.text = nil
            cell.totalLikesCount.text = nil
            cell.likedByLbl.text = nil
            
            guard let postUid = post.uid ,
                  let postName = post.name ,
                  let profileImgUrl = post.profileImageUrl ,
                  let postImageURLs = post.postImageURLs,
                  let postLocation = post.location,
                  let postCaption = post.caption ,
                  let postComments = post.comments,
                  let postUserName = post.username,
                  let postLikesCounts = post.likesCount,
                  let postLikedBy = post.likedBy,
                  let postPostDocumentID = post.postDocumentID else { return UITableViewCell()}
            
            
            cell.steperControl.numberOfPages = post.postImageURLs?.count ?? 0
            cell.steperControl.currentPage = 0
            DispatchQueue.main.async { [weak self] in
                ImageLoader.loadImage(for: URL(string: postImageURLs[0]), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            }
            cell.steperControlPressed = { [weak self] pageIndex in
                print(postImageURLs[pageIndex])
                DispatchQueue.main.async { [weak self] in
                    ImageLoader.loadImage(for: URL(string: postImageURLs[pageIndex]), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                }
            }
            
            
            DispatchQueue.main.async { [weak self] in
                ImageLoader.loadImage(for: URL(string:profileImgUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.userName.text = postName
                cell.postLocationLbl.text = postLocation
                cell.postCaption.text = postCaption
                cell.totalLikesCount.text = "\(postLikesCounts) Likes"
            }
            
            
            disPatchGroup.enter()
            DispatchQueue.main.async { [weak self] in
                if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
                    
                    if (postLikedBy.contains(uid)){
                        cell.isLiked = true
                        let imageName = cell.isLiked ? "heart.fill" : "heart"
                        cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                        cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                    }else{
                        cell.isLiked = false
                        let imageName = cell.isLiked ? "heart.fill" : "heart"
                        cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                        cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                    }
                    
                    cell.doubleTapAction = { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.likePost(postPostDocumentID: postPostDocumentID, uid: uid, postUid: postUid, cell: cell)
                    }
                    
                    cell.likeBtnTapped = { [weak self] in
                        if cell.isLiked {
                            self?.viewModel.unLikePost(postPostDocumentID: postPostDocumentID, uid: uid, cell: cell)
                        } else {
                            self?.viewModel.likePost(postPostDocumentID: postPostDocumentID, uid: uid, postUid: postUid, cell: cell)
                        }
                    }
                    
                }
                self?.disPatchGroup.leave()
            }
            
            disPatchGroup.enter()
            DispatchQueue.main.async { [weak self] in
                cell.commentsBtnTapped = { [weak self] in
                    let storyboard = UIStoryboard.Common
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                    destinationVC.allPost = post
                    self?.navigationController?.pushViewController(destinationVC, animated: true)
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
                for i in 0..<maxUsersToShow {
                    let likedUser = postLikedBy[i]
                    FetchUserData.shared.fetchUserDataByUid(uid: likedUser) { [weak self] result in
                        switch result {
                        case .success(let data):
                            if let data = data, let profileImgUrl = data.imageUrl , let name = data.name  {
                                let imageView: UIImageView
                                switch i {
                                case 0:
                                    cell.likedBysectionView.isHidden = false
                                    cell.userImg2View.isHidden = false
                                    imageView = cell.userImg2
                                    cell.likedByLbl.text = "Liked by \(name) and \(Int(postLikedBy.count - 1)) others."
                                case 1:
                                    cell.userImg3View.isHidden = false
                                    imageView = cell.userImg3
                                case 2:
                                    cell.userImg4View.isHidden = false
                                    imageView = cell.userImg4
                                default:
                                    return
                                }
                                ImageLoader.loadImage(for: URL(string: profileImgUrl), into: imageView, withPlaceholder: UIImage(systemName: "person.fill"))
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
            
            disPatchGroup.notify(queue: .main){}
            
            return cell
        }
      return UITableViewCell()
    }
}
