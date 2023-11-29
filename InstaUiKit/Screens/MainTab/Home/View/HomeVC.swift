//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import FirebaseAuth
import SkeletonView
import RxSwift

class HomeVC: UIViewController {
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var userImg: CircleImageView!
    
    var imgURL: URL?
    var userName: String?
    var allPost = [PostModel]()
    var allUniqueUsersArray = [UserModel]()
    var uid: String?
    var refreshControl = UIRefreshControl()
    var viewModel = HomeVCViewModel()
    let disPatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupRefreshControl()
        configureUI()
        
//        CDUserManager.shared.createUser(user: CDUsersModel(id: UUID(), email: "darshan@gmail.com", password: "123456", uid: "uid")) { bool in
//            print(bool)
//        }
        
        CDUserManager.shared.readUser { result in
            switch result {
            case.success(let data):
                if let data = data {
                  print(data)
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func configureTableView() {
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
        makeSkeletonable()
    }
    
    private func makeSkeletonable(){
        feedTableView.isSkeletonable = true
        feedTableView.showAnimatedGradientSkeleton()
        storiesCollectionView.isSkeletonable = true
        storiesCollectionView.showAnimatedGradientSkeleton()
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        feedTableView.addSubview(refreshControl)
    }
    
    @objc private func refresh() {
        self.makeSkeletonable()
        disPatchGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateUI()
            self.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func addStoryBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "AddStoryVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    
    @IBAction func directMsgBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "DirectMsgVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    private func configureUI() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        uid = currentUid
        updateUI()
    }
}

// MARK: - Update UI

extension HomeVC {
    func updateUI() {
        disPatchGroup.enter()
        DispatchQueue.main.async {
            self.fetchData()
            self.disPatchGroup.leave()
        }
        disPatchGroup.enter()
        DispatchQueue.main.async {
            self.loadProfileImage()
            self.disPatchGroup.leave()
        }
        disPatchGroup.enter()
        DispatchQueue.main.async {
            self.loadUserName()
            self.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main){}
    }
    
    private func fetchData() {
        disPatchGroup.enter()
        Data.shared.getData(key: "ProfileUrl") { (result:Result< String? , Error >) in
            self.disPatchGroup.leave()
            if case .success(let urlString) = result, let url = URL(string: urlString ?? "") {
                self.imgURL = url
            }
        }
        
        disPatchGroup.enter()
        Data.shared.getData(key: "Name") { (result:Result< String? , Error >) in
            self.disPatchGroup.leave()
            if case .success(let data) = result {
                self.userName = data
            }
        }
        
        disPatchGroup.enter()
        viewModel.fetchAllPostsOfFollowings { result in
            self.disPatchGroup.leave()
            if case .success(let posts) = result {
                if let posts = posts {
                    self.allPost = posts
                }
                self.feedTableView.stopSkeletonAnimation()
                self.view.stopSkeletonAnimation()
                self.feedTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self.feedTableView.reloadData()
            }
        }
        
        disPatchGroup.enter()
        DispatchQueue.main.async {
            self.loadProfileImage()
            self.disPatchGroup.leave()
        }
        
        disPatchGroup.enter()
        DispatchQueue.main.async {
            self.fetchUniqueUsers()
            self.disPatchGroup.leave()
        }
        
        disPatchGroup.notify(queue: .main){}
        
    }
    
    private func loadProfileImage() {
        if let url = imgURL {
            ImageLoader.loadImage(for: url, into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
    }
    
    private func loadUserName() {
        Data.shared.getData(key: "Name") { (result:Result< String? , Error >) in
            if case .success(let data) = result {
                self.userName = data
            }
        }
    }
    
    private func fetchUniqueUsers() {
        viewModel.fetchFollowingUsers { result in
            if case .success(let data) = result {
                if let data = data {
                    self.allUniqueUsersArray = data
                }
                self.storiesCollectionView.stopSkeletonAnimation()
                self.view.stopSkeletonAnimation()
                self.storiesCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self.storiesCollectionView.reloadData()
            }
        }
    }
}

extension HomeVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let post = allPost[indexPath.row]
        
        disPatchGroup.enter()
        ProfileViewModel.shared.fetchUserData(uid: post.uid) { result in
            self.disPatchGroup.leave()
            switch result {
            case.success(let data):
                if let imgUrl = data.imageUrl , let name = data.name {
                    ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                    ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                    cell.userName.text = name
                }
            case.failure(let error):
                print(error)
            }
        }
        
        disPatchGroup.enter()
        DispatchQueue.main.async {
            ImageLoader.loadImage(for: URL(string: post.postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.postLocationLbl.text = post.location
            cell.postCaption.text = post.caption
            cell.totalLikesCount.text = "\(post.likesCount) Likes"
            self.disPatchGroup.leave()
        }
        
        disPatchGroup.enter()
        if let randomLikedByUID = post.likedBy.randomElement() {
            ProfileViewModel.shared.fetchUserData(uid: randomLikedByUID) { result in
                self.disPatchGroup.leave()
                switch result {
                case .success(let data):
                    if let name = data.name {
                        cell.likedByLbl.text = "Liked by \(name) and \(Int(post.likedBy.count - 1)) others."
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        disPatchGroup.enter()
        
        DispatchQueue.main.async {
            if let uid = self.uid {
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
                                
                                ProfileViewModel.shared.fetchUserData(uid: post.uid) { result in
                                    switch result {
                                    case.success(let data):
                                        if let fmcToken = data.fcmToken {
                                            Data.shared.getData(key: "Name") {  (result: Result<String?, Error>) in
                                                switch result {
                                                case .success(let name):
                                                    if let name = name {
                                                        PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Liked your post.")
                                                    }
                                                case.failure(let error):
                                                    print(error)
                                                }
                                            }
                                        }
                                    case.failure(let error):
                                        print(error)
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            self.disPatchGroup.leave()
        }
        
        disPatchGroup.enter()
        DispatchQueue.main.async {
            cell.commentsBtnTapped = { [weak self] in
                let storyboard = UIStoryboard.Common
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                destinationVC.allPost = post
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
            self.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main){}
        
        return cell
    }
    
}


extension HomeVC: SkeletonCollectionViewDataSource  , SkeletonCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allUniqueUsersArray.count
    }
    
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "StoriesCell"
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
        if let uid = allUniqueUsersArray[indexPath.row].uid,
           let name = allUniqueUsersArray[indexPath.row].name,
           let imgUrl = allUniqueUsersArray[indexPath.row].imageUrl{
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.userName.text = name
            }
        }
        return cell
    }
    
}


