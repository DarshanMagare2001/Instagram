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
    var allPost : [PostAllDataModel]?
    var uid : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        postTableViewOutlet.register(nib, forCellReuseIdentifier: "FeedCell")
        if let currentUid = Auth.auth().currentUser?.uid {
            uid = currentUid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        postTableViewOutlet.reloadData()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
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
            cell.userName.text = nil
            cell.postImg.image = nil
            cell.postLocationLbl.text = nil
            cell.postCaption.text = nil
            cell.totalLikesCount.text = nil
            cell.likedByLbl.text = nil
            
            guard let postUid = post.uid ,
                  let postName = post.name ,
                  let profileImgUrl = post.profileImageUrl ,
                  let postImageURL = post.postImageURL,
                  let postLocation = post.location,
                  let postCaption = post.caption ,
                  let postComments = post.comments,
                  let postUserName = post.username,
                  let postLikesCounts = post.likesCount,
                  let postLikedBy = post.likedBy,
                  let postPostDocumentID = post.postDocumentID else { return UITableViewCell()}
            
            
            DispatchQueue.main.async { [weak self] in
                ImageLoader.loadImage(for: URL(string:profileImgUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                ImageLoader.loadImage(for: URL(string:profileImgUrl), into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                ImageLoader.loadImage(for: URL(string: postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.postLocationLbl.text = postLocation
                cell.postCaption.text = postCaption
                cell.totalLikesCount.text = "\(postLikesCounts) Likes"
                cell.userName.text = postName
            }
            
            
            if let randomLikedByUID = postLikedBy.randomElement() {
                FetchUserInfo.shared.fetchUserDataByUid(uid: randomLikedByUID) { result in
                    switch result {
                    case .success(let data):
                        if let data = data , let name = data.name {
                            cell.likedByLbl.text = "Liked by \(name) and \(Int(postLikedBy.count - 1)) others."
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            if let uid = uid {
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
                
                cell.likeBtnTapped = { [weak self] in
                    if cell.isLiked {
                        PostViewModel.shared.unlikePost(postDocumentID: postPostDocumentID, userUID: uid) { success in
                            if success {
                                // Update the UI: Set the correct image for the like button
                                cell.isLiked = false
                                let imageName = cell.isLiked ? "heart.fill" : "heart"
                                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                            }
                        }
                    } else {
                        PostViewModel.shared.likePost(postDocumentID: postPostDocumentID, userUID: uid) { success in
                            if success {
                                // Update the UI: Set the correct image for the like button
                                cell.isLiked = true
                                let imageName = cell.isLiked ? "heart.fill" : "heart"
                                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                            }
                        }
                    }
                }
            }
            
            cell.commentsBtnTapped = { [weak self] in
                let storyboard = UIStoryboard.Common
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                destinationVC.allPost = post
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
        return cell
    }
}
