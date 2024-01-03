//
//  LikesVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SkeletonView

protocol LikesVCProtocol : class {
    func setUpCells()
    func setUpRefreshControl()
    func startSkeleton()
    func stopSkeleton()
    func reloadTableView()
}

class LikesVC : UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var presenter : LikesVCPresenterProtocol?
    var interactor : LikesVCInteractorProtocol?
    var refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
}

extension LikesVC : LikesVCProtocol {
   
    func setUpCells(){
        let nibLikes = UINib(nibName: "LikesCell", bundle: nil)
        let nibFollowing = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nibLikes, forCellReuseIdentifier: "LikesCell")
        tableViewOutlet.register(nibFollowing, forCellReuseIdentifier: "FollowingCell")
    }
    
    func setUpRefreshControl(){
        refreshControll.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableViewOutlet.addSubview(refreshControll)
    }
    
    func startSkeleton(){
        self.view.showAnimatedGradientSkeleton()
        self.tableViewOutlet.isSkeletonable = true
        self.tableViewOutlet.showAnimatedGradientSkeleton()
    }
    
    func stopSkeleton(){
        self.tableViewOutlet.stopSkeletonAnimation()
        self.view.stopSkeletonAnimation()
        self.tableViewOutlet.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
    }
    
    func reloadTableView() {
        stopSkeleton()
        tableViewOutlet.reloadData()
    }
    
    @objc func refresh(send: UIRefreshControl) {
        self.startSkeleton()
        DispatchQueue.main.asyncAfter(deadline:.now()+1) {
            self.presenter?.fetchPostDataOfPerticularUser(completion: {
                self.stopSkeleton()
                self.refreshControll.endRefreshing()
            })
        }
    }
    
}


extension LikesVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return interactor?.allPost.count ?? 0
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "LikesCell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < interactor?.allPost.count ?? 0 {
            if let likedBy = interactor?.allPost[section].likedBy {
                let filteredLikes = likedBy.filter { $0 != interactor?.currentUserUid }
                return filteredLikes.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let likesCell = tableView.dequeueReusableCell(withIdentifier: "LikesCell", for: indexPath) as! LikesCell
        let section = indexPath.section
        let row = indexPath.row
        guard let postLikedBy = interactor?.allPost[section].likedBy else {return UITableViewCell()}
        if section < interactor?.allPost.count ?? 0 && row < postLikedBy.count {
            let uid = postLikedBy.filter { $0 != interactor?.currentUserUid }
            DispatchQueue.main.async {
                FetchUserData.shared.fetchUserDataByUid(uid: uid[indexPath.row]) { result in
                    switch result {
                    case.success(let user):
                        if let user = user {
                            if let imgUrl = user.imageUrl, let name = user.name {
                                ImageLoader.loadImage(for: URL(string: imgUrl), into: likesCell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                                likesCell.likeByLbl.text = "\(name) liked your post"
                            }
                            
                            likesCell.userImgPressed = { [weak self] in
                                let destinationVC = UsersProfileViewBuilder.build(user: user, isFollowAndMsgBtnShow: true)
                                self?.navigationController?.pushViewController(destinationVC, animated: true)
                            }
                            
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
                
                if let imageURL = URL(string:self.interactor?.allPost[section].postImageURLs?[0] ?? "") {
                    ImageLoader.loadImage(for: imageURL, into: likesCell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                }
                
            }
        }
        return likesCell
    }
}


