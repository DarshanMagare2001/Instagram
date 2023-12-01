//
//  UsersProfileView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/11/23.
//

import UIKit

class UsersProfileView: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var totalPostCount: UILabel!
    @IBOutlet weak var totalFollowersCount: UILabel!
    @IBOutlet weak var totalFollowingCount: UILabel!
    @IBOutlet weak var folloBtn: UIButton!
    @IBOutlet weak var headLine: UILabel!
    @IBOutlet weak var msgBtn: UIButton!
    
    var allPost = [PostModel]()
    var user : UserModel?
    var viewModel = UsersProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.msgBtn.isHidden = true
        updateCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = user {
            if let uid = user.uid , let followers = user.followers?.count , let followings = user.followings?.count , let followersRequest = user.followersRequest {
                
                FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
                    switch result {
                    case.success(let userData):
                        if let userData = userData , let currentUid = userData.uid {
                            if followersRequest.contains(currentUid){
                                self.folloBtn.setTitle("Requested", for: .normal)
                                self.msgBtn.isHidden = true
                            }else if let userFollowings = user.followers{
                                if (userFollowings.contains(currentUid)){
                                    self.folloBtn.setTitle("UnFollow", for: .normal)
                                    self.msgBtn.isHidden = false
                                }else{
                                    self.folloBtn.setTitle("Follow", for: .normal)
                                    self.msgBtn.isHidden = true
                                }
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
                
                PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                    switch result {
                    case.success(let data):
                        self.allPost = data
                        self.totalPostCount.text = "\(data.count)"
                        self.collectionViewOutlet.reloadData()
                    case.failure(let error):
                        print(error)
                    }
                }
                totalFollowersCount.text = "\(followers)"
                totalFollowingCount.text = "\(followings)"
                
            }
            if let imgUrl = user.imageUrl , let names = user.name , let bio = user.bio  , let username = user.username {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                name.text = username
                headLine.text = names
                userBio.text = bio
            }
        }
    }
    
    func updateCell() {
        // Configure the collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2 // Adjust the spacing between cells horizontally
        flowLayout.minimumLineSpacing = 2 // Adjust the spacing between cells vertically
        collectionViewOutlet.collectionViewLayout = flowLayout
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func folloBtnPressed(_ sender: UIButton) {
        if let user = user {
            if let uid = user.uid , let isPrivate = user.isPrivate  {
                FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
                    switch result {
                    case.success(let userData):
                        if let userData = userData {
                            if let followings = userData.followings , let followingRequest = userData.followingsRequest {
                                if (followings.contains(uid)) || (followingRequest.contains(uid)) {
                                    self.unFollow()
                                    self.removeFollowRequest()
                                    self.folloBtn.setTitle("Follow", for: .normal)
                                    self.msgBtn.isHidden = true
                                }else{
                                    if isPrivate == "false" {
                                        self.follow()
                                        self.folloBtn.setTitle("UnFollow", for: .normal)
                                        self.msgBtn.isHidden = false
                                    }else{
                                        self.followRequest()
                                        self.folloBtn.setTitle("Requested", for: .normal)
                                    }
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
    
    @IBAction func messageBtnPressed(_ sender: UIButton) {
        if let user = user {
            let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            destinationVC.receiverUser = user
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func follow(){
        viewModel.saveFollower(uid: user?.uid) { result  in
            switch result {
            case.success(let value):
                Data.shared.getData(key: "Name") {  (result: Result<String?, Error>) in
                    switch result {
                    case .success(let name):
                        if let name = name {
                            if let fmcToken = self.user?.fcmToken {
                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Started following you.")
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func unFollow(){
        viewModel.removeFollower(uid: user?.uid) { result in
            switch result {
            case.success(let value):
                print(value)
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func followRequest(){
        viewModel.requestFollower(uid: user?.uid) { result  in
            switch result {
            case.success(let value):
                Data.shared.getData(key: "Name") {  (result: Result<String?, Error>) in
                    switch result {
                    case .success(let name):
                        if let name = name {
                            if let fmcToken = self.user?.fcmToken {
                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "Follow Request" , body: "\(name) requested to follow you.")
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func removeFollowRequest(){
        viewModel.removeFollowRequest(uid: user?.uid) { result  in
            switch result {
            case.success(let value):
                print(value)
            case.failure(let error):
                print(error)
            }
        }
    }
    
}

extension UsersProfileView: UICollectionViewDelegate, UICollectionViewDataSource , UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersProfileViewCell", for: indexPath) as! UsersProfileViewCell
        if let imageURL = URL(string: allPost[indexPath.row].postImageURL) {
            ImageLoader.loadImage(for: imageURL, into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            tapGesture.delegate = self
            cell.postImg.addGestureRecognizer(tapGesture)
            cell.postImg.isUserInteractionEnabled = true
        }
        return cell
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FeedViewVC") as! FeedViewVC
        destinationVC.allPost = allPost
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}
