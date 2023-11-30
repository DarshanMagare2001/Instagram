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
    var allPost : [PostModel]?
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
            DispatchQueue.main.async {
                FetchUserInfo.shared.fetchUserDataByUid(uid: post.uid) { result in
                    switch result {
                    case.success(let data):
                        if let data = data , let imgUrl = data.imageUrl , let name = data.name {
                            ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                            ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                            cell.userName.text = name
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
            }
            ImageLoader.loadImage(for: URL(string: post.postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.postLocationLbl.text = post.location
            cell.postCaption.text = post.caption
            cell.totalLikesCount.text = "\(post.likesCount) Likes"
            
            if let randomLikedByUID = post.likedBy.randomElement() {
                FetchUserInfo.shared.fetchUserDataByUid(uid: randomLikedByUID) { result in
                    switch result {
                    case .success(let data):
                        if let data = data , let name = data.name {
                            cell.likedByLbl.text = "Liked by \(name) and \(Int(post.likedBy.count - 1)) others."
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            if let uid = uid {
                if (post.likedBy.contains(uid)){
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
                        PostViewModel.shared.unlikePost(postDocumentID: post.postDocumentID, userUID: uid) { success in
                            if success {
                                // Update the UI: Set the correct image for the like button
                                cell.isLiked = false
                                let imageName = cell.isLiked ? "heart.fill" : "heart"
                                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                            }
                        }
                    } else {
                        PostViewModel.shared.likePost(postDocumentID: post.postDocumentID, userUID: uid) { success in
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
