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
    var allPost = [PostAllDataModel]()
    var allUniqueUsersArray = [UserModel]()
    var refreshControl = UIRefreshControl()
    var viewModel = HomeVCViewModel()
    var notificationCountForDirectMsg : Int = 0
    var notificationCountForNotificationBtn: Int = 0
    var isnotificationShowForDirectMsg = false
    var isnotificationShowForNotificationBtn = false
    let disPatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarItemsForHomeVC(isdirectMsgHaveNotification: isnotificationShowForDirectMsg, isNotificationBtnHaveNotification: isnotificationShowForNotificationBtn, notificationCountForDirectMsg: notificationCountForDirectMsg, notificationCountForNotificationBtn: notificationCountForNotificationBtn)
        configureTableView()
        setupRefreshControl()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllKindNotifications()
    }
    
    private func setBarItemsForHomeVC(isdirectMsgHaveNotification: Bool, isNotificationBtnHaveNotification: Bool, notificationCountForDirectMsg: Int, notificationCountForNotificationBtn: Int) {
        if let mainTabVC = tabBarController as? MainTabVC {
            mainTabVC.setBarItemsForHomeVC(isdirectMsgHaveNotification: isdirectMsgHaveNotification, isNotificationBtnHaveNotification: isNotificationBtnHaveNotification, notificationCountForDirectMsg: notificationCountForDirectMsg, notificationCountForNotificationBtn: notificationCountForNotificationBtn) { buttonType in
                switch buttonType {
                case .directMessage:
                    Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "DirectMsgVC") { [weak self] destinationVC in
                        if let destinationVC = destinationVC {
                            self?.navigationController?.pushViewController(destinationVC, animated: true)
                        }
                    }
                case .notification:
                    Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "NotificationVC") { [weak self] destinationVC in
                        if let destinationVC = destinationVC {
                            self?.navigationController?.pushViewController(destinationVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchAllKindNotifications(){
        disPatchGroup.enter()
        viewModel.fetchAllNotifications { [weak self] result in
            switch result {
            case.success(let notificationCount):
                print(notificationCount)
                if notificationCount != 0 {
                    self?.isnotificationShowForNotificationBtn = true
                    self?.notificationCountForNotificationBtn = notificationCount
                }else{
                    self?.isnotificationShowForNotificationBtn = false
                }
            case.failure(let error):
                print(error)
            }
            self?.disPatchGroup.leave()
        }
        
        disPatchGroup.enter()
        viewModel.fetchUserChatNotificationCount { [weak self] result in
            switch result {
            case.success(let notificationCount):
                print(notificationCount)
                if let notificationCount = notificationCount {
                    if notificationCount != 0 {
                        self?.isnotificationShowForDirectMsg = true
                        self?.notificationCountForDirectMsg = notificationCount
                    }else{
                        self?.isnotificationShowForDirectMsg = false
                    }
                }
            case.failure(let error):
                print(error)
            }
            self?.disPatchGroup.leave()
        }
        
        disPatchGroup.notify(queue: .main) {
            self.setBarItemsForHomeVC(isdirectMsgHaveNotification: self.isnotificationShowForDirectMsg, isNotificationBtnHaveNotification: self.isnotificationShowForNotificationBtn, notificationCountForDirectMsg: self.notificationCountForDirectMsg, notificationCountForNotificationBtn: self.notificationCountForNotificationBtn)
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
            }
        }
    }
}

extension HomeVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        if section == 1 {
            return allPost.count
        }
        return 0
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "HomeVCCell", for: indexPath) as! HomeVCCell
            cell2.allUniqueUsersArray = allUniqueUsersArray
            cell2.addStoryBtnPressed = { [weak self] in
                Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "AddStoryVC") { [weak self] destinationVC in
                    if let destinationVC = destinationVC {
                        self?.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }
            return cell2
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(didDoubleTap(_ :)))
            tapGesture.numberOfTapsRequired = 2
            let post = allPost[indexPath.row]
            
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
                cell.userName.text = postName
                cell.postLocationLbl.text = postLocation
                cell.postCaption.text = postCaption
                cell.totalLikesCount.text = "\(postLikesCounts) Likes"
            }
            
            cell.postImg.addGestureRecognizer(tapGesture)
            cell.postImg.clipsToBounds = true
            
            disPatchGroup.enter()
            if let randomLikedByUID = postLikedBy.randomElement() {
                FetchUserInfo.shared.fetchUserDataByUid(uid: randomLikedByUID) { [weak self] result in
                    self?.disPatchGroup.leave()
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
            
            
            disPatchGroup.enter()
            DispatchQueue.main.async { [weak self] in
                if let uid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) {
                    
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
                            PostViewModel.shared.likePost(postDocumentID: postPostDocumentID, userUID: uid) { [weak self] success in
                                if success {
                                    // Update the UI: Set the correct image for the like button
                                    cell.isLiked = true
                                    let imageName = cell.isLiked ? "heart.fill" : "heart"
                                    cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                                    cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                                    FetchUserInfo.shared.fetchUserDataByUid(uid: postUid) { [weak self] result in
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
        return UITableViewCell()
    }
    
    @objc func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let gestureView = gesture.view, let postImg = gestureView as? UIImageView else { return }

        let size = min(postImg.frame.size.width, postImg.frame.size.height) / 3
        let heart = UIImageView(image: UIImage(systemName: "heart.fill"))
        heart.frame = CGRect(x: (postImg.frame.size.width - size) / 2,
                             y: (postImg.frame.size.height - size) / 2,
                             width: size,
                             height: size)
        heart.tintColor = .red
        postImg.addSubview(heart)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.5, animations: {
                heart.alpha = 0
            }, completion: { done in
                if done {
                    heart.removeFromSuperview()
                }
            })
        }
    }

    
}



