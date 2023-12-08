//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SkeletonView
import RxSwift

class HomeVC: UIViewController {
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var notificationLbl: CircularLabel!
    @IBOutlet weak var directMsgNotificationLbl: CircularLabel!
    @IBOutlet weak var storyView: UIView!
    var allPost = [PostModel]()
    var allUniqueUsersArray = [UserModel]()
    var refreshControl = UIRefreshControl()
    var viewModel = HomeVCViewModel()
    var lastOffset: CGFloat = 0
    let disPatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationLbl.isHidden = true
        directMsgNotificationLbl.isHidden = true
        configureTableView()
        setupRefreshControl()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAllKindNotifications()
    }
    
    private func fetchAllKindNotifications(){
        viewModel.fetchAllNotifications { [weak self] result in
            switch result {
            case.success(let notificationCount):
                print(notificationCount)
                if notificationCount != 0 {
                    self?.notificationLbl.isHidden = false
                    self?.notificationLbl.text = "\(notificationCount)"
                }else{
                    self?.notificationLbl.isHidden = true
                }
            case.failure(let error):
                print(error)
            }
        }
        
        viewModel.fetchUserChatNotificationCount { [weak self] result in
            switch result {
            case.success(let notificationCount):
                print(notificationCount)
                if let notificationCount = notificationCount {
                    if notificationCount != 0 {
                        self?.directMsgNotificationLbl.isHidden = false
                        self?.directMsgNotificationLbl.text = "\(notificationCount)"
                    }else{
                        self?.directMsgNotificationLbl.isHidden = true
                    }
                }
            case.failure(let error):
                print(error)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.updateUI()
            self?.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func addStoryBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "AddStoryVC") { [weak self] destinationVC in
            if let destinationVC = destinationVC {
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    
    @IBAction func directMsgBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "DirectMsgVC") { [weak self] destinationVC in
            if let destinationVC = destinationVC {
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    
    @IBAction func notificationBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "NotificationVC") { [weak self] destinationVC in
            if let destinationVC = destinationVC {
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    private func configureUI() {
        updateUI()
    }
}

// MARK: - Update UI

extension HomeVC {
    func updateUI() {
        fetchAllKindNotifications()
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            self?.fetchData()
            self?.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main){}
    }
    
    private func fetchData() {
        
        if let url = FetchUserInfo.fetchUserInfoFromUserdefault(type: .profileUrl){
            ImageLoader.loadImage(for: URL(string:url), into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
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
        DispatchQueue.main.async { [weak self] in
            self?.fetchUniqueUsers()
            self?.disPatchGroup.leave()
        }
        
        disPatchGroup.notify(queue: .main){}
        
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
        
        cell.userImg1.image = nil
        cell.userImg2.image = nil
        cell.userName.text = nil
        cell.postImg.image = nil
        cell.postLocationLbl.text = nil
        cell.postCaption.text = nil
        cell.totalLikesCount.text = nil
        cell.likedByLbl.text = nil
        
        disPatchGroup.enter()
        FetchUserInfo.shared.fetchUserDataByUid(uid: post.uid) { [weak self] result in
            self?.disPatchGroup.leave()
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
        
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            ImageLoader.loadImage(for: URL(string: post.postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.postLocationLbl.text = post.location
            cell.postCaption.text = post.caption
            cell.totalLikesCount.text = "\(post.likesCount) Likes"
            self?.disPatchGroup.leave()
        }
        
        disPatchGroup.enter()
        if let randomLikedByUID = post.likedBy.randomElement() {
            FetchUserInfo.shared.fetchUserDataByUid(uid: randomLikedByUID) { [weak self] result in
                self?.disPatchGroup.leave()
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
        
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            if let uid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) {
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
                        PostViewModel.shared.likePost(postDocumentID: post.postDocumentID, userUID: uid) { [weak self] success in
                            if success {
                                // Update the UI: Set the correct image for the like button
                                cell.isLiked = true
                                let imageName = cell.isLiked ? "heart.fill" : "heart"
                                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                                
                                FetchUserInfo.shared.fetchUserDataByUid(uid: post.uid) { [weak self] result in
                                    switch result {
                                    case.success(let data):
                                        if let data = data , let fmcToken = data.fcmToken {
                                            if let name = FetchUserInfo.fetchUserInfoFromUserdefault(type: .name) {
                                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Liked your post.")
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
        disPatchGroup.notify(queue: .main){}
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let sensitivity: CGFloat = 10.0
        if offset < lastOffset - sensitivity {
            UIView.animate(withDuration: 0.3) {
                self.storyView.isHidden = false
                self.storyView.alpha = 1.0
            }
        } else if offset > lastOffset + sensitivity {
            UIView.animate(withDuration: 0.3) {
                self.storyView.alpha = 0.0
            } completion: { _ in
                self.storyView.isHidden = true
            }
        }
        lastOffset = offset
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
            DispatchQueue.main.async { [weak self] in
                ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.userName.text = name
            }
        }
        return cell
    }
    
}


