//
//  LikesVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SkeletonView

class LikesVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    var allPost = [PostModel]()
    var currentUserUid: String?
    var currentUser: UserModel?
    var refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibLikes = UINib(nibName: "LikesCell", bundle: nil)
        let nibFollowing = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nibLikes, forCellReuseIdentifier: "LikesCell")
        tableViewOutlet.register(nibFollowing, forCellReuseIdentifier: "FollowingCell")
        refreshControll.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableViewOutlet.addSubview(refreshControll)
        fetchData()
        self.view.showAnimatedGradientSkeleton()
        self.tableViewOutlet.isSkeletonable = true
        self.tableViewOutlet.showAnimatedGradientSkeleton()
    }
    
    @objc func refresh(send: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fetchData()
            self.view.showAnimatedGradientSkeleton()
            self.tableViewOutlet.isSkeletonable = true
            self.tableViewOutlet.showAnimatedGradientSkeleton()
            self.refreshControll.endRefreshing()
        }
    }
    
    func fetchData() {
        if let uid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) {
            self.currentUserUid = uid
            PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                switch result {
                case .success(let images):
                    // Handle the images
                    print("Fetched images: \(images)")
                    DispatchQueue.main.async {
                        self.allPost = images
                        self.tableViewOutlet.stopSkeletonAnimation()
                        self.view.stopSkeletonAnimation()
                        self.tableViewOutlet.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                        self.tableViewOutlet.reloadData()
                    }
                case .failure(let error):
                    // Handle the error
                    print("Error fetching images: \(error)")
                }
            }
        }
    }
}

extension LikesVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allPost.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "LikesCell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < allPost.count {
            let filteredLikes = allPost[section].likedBy.filter { $0 != currentUserUid }
            return filteredLikes.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let likesCell = tableView.dequeueReusableCell(withIdentifier: "LikesCell", for: indexPath) as! LikesCell
        let section = indexPath.section
        let row = indexPath.row
        if section < allPost.count && row < allPost[section].likedBy.count {
            let uid = allPost[section].likedBy.filter { $0 != currentUserUid }
            DispatchQueue.main.async {
                
                FetchUserInfo.shared.fetchUserDataByUid(uid: uid[indexPath.row]) { result in
                    switch result {
                    case.success(let user):
                        if let user = user {
                            if let imgUrl = user.imageUrl, let name = user.name {
                                ImageLoader.loadImage(for: URL(string: imgUrl), into: likesCell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                                likesCell.likeByLbl.text = "\(name) liked your post"
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
                
                if let imageURL = URL(string: self.allPost[section].postImageURL) {
                    ImageLoader.loadImage(for: imageURL, into: likesCell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                }
            }
        }
        return likesCell
    }
}

