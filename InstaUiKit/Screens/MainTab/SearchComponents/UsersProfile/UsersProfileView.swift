//
//  UsersProfileView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/11/23.
//

import UIKit

protocol UsersProfileViewProtocol : class {
    func setUpMsgBtnAndFollowBtn()
    func verifyIsPrivateOrNot()
    func updateCell(flowLayout:UICollectionViewLayout)
}

class UsersProfileView: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var totalPostCount: UILabel!
    @IBOutlet weak var totalFollowersCount: UILabel!
    @IBOutlet weak var totalFollowingCount: UILabel!
    @IBOutlet weak var folloBtn: UIButton!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var postTextLbl: UILabel!
    @IBOutlet weak var followersTextLbl: UILabel!
    @IBOutlet weak var followingsTextLbl: UILabel!
    @IBOutlet weak var isPrivateAccountBoard: UIView!
    
    var presenter : UsersProfileViewPresenterProtocol?
    var interactor : UsersProfileViewInteractorProtocol?
    var viewModel = UsersProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidload()
        
       
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserImg))
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(tapGesture)
        
        let followingsTextLblTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingsTextLblTapped))
        followingsTextLbl.addGestureRecognizer(followingsTextLblTapGesture)
        
        let followersTextLblTapGesture = UITapGestureRecognizer(target: self, action: #selector(followersTextLblTapped))
        followersTextLbl.addGestureRecognizer(followersTextLblTapGesture)
        
        let postTextLblTapGesture = UITapGestureRecognizer(target: self, action: #selector(postTextLblTapped))
        postTextLbl.addGestureRecognizer(postTextLblTapGesture)
        
        
        
        
        
    }
    
    
    
    @objc func postTextLblTapped(){
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FeedViewVC") as! FeedViewVC
        destinationVC.allPost = interactor?.allPost
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @objc func followingsTextLblTapped() {
        goToFollowerAndFollowing()
    }
    
    @objc func followersTextLblTapped() {
        goToFollowerAndFollowing()
    }
    
    
    @objc func didTapUserImg() {
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ProfilePresentedView") as! ProfilePresentedView
        destinationVC.user = interactor?.user
        destinationVC.modalPresentationStyle = .overFullScreen
        present(destinationVC, animated: true, completion: nil)
    }
    
    func makeLblsUserInteractable(){
        followingsTextLbl.isUserInteractionEnabled = true
        followersTextLbl.isUserInteractionEnabled = true
        postTextLbl.isUserInteractionEnabled = true
    }
    
    func makeLblsUserUnInteractable(){
        followingsTextLbl.isUserInteractionEnabled = false
        followersTextLbl.isUserInteractionEnabled = false
        postTextLbl.isUserInteractionEnabled = false
    }
    
    func goToFollowerAndFollowing(){
        if let user = interactor?.user {
            let storyboard = UIStoryboard.Common
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "FollowersAndFollowingVC") as! FollowersAndFollowingVC
            destinationVC.user = user
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    self.interactor?.currentUser = user
                }
            case.failure(let error):
                print(error)
            }
        }
        
        
        if let user = interactor?.user {
            if let uid = user.uid , let followers = user.followers?.count , let followings = user.followings?.count , let followersRequest = user.followersRequest {
                
                if (interactor?.isFollowAndMsgBtnShow!)!{
                    FetchUserData.shared.fetchCurrentUserFromFirebase { result in
                        switch result {
                        case.success(let userData):
                            if let userData = userData , let currentUid = userData.uid {
                                if followersRequest.contains(currentUid){
                                    self.folloBtn.setTitle("Requested", for: .normal)
                                    self.msgBtn.isHidden = true
                                    self.isPrivateAccountBoard.isHidden = false
                                    self.makeLblsUserUnInteractable()
                                }else if let userFollowings = user.followers{
                                    if (userFollowings.contains(currentUid)){
                                        self.folloBtn.setTitle("UnFollow", for: .normal)
                                        self.msgBtn.isHidden = false
                                        self.isPrivateAccountBoard.isHidden = true
                                        self.makeLblsUserInteractable()
                                    }else{
                                        self.folloBtn.setTitle("Follow", for: .normal)
                                        self.msgBtn.isHidden = true
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
                PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                    switch result {
                    case.success(let data):
                        self.interactor?.allPost = data
                        self.totalPostCount.text = "\(data.count)"
                        self.collectionViewOutlet.reloadData()
                    case.failure(let error):
                        print(error)
                    }
                }
                totalFollowersCount.text = "\(followers)"
                totalFollowingCount.text = "\(followings)"
                
            }
            if let imgUrl = user.imageUrl, let bio = user.bio  , let username = user.username {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                name.text = username
                userBio.text = bio
            }
        }
    }
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    @IBAction func folloBtnPressed(_ sender: UIButton) {
        if let user = interactor?.user {
            if let uid = user.uid , let isPrivate = user.isPrivate  {
                FetchUserData.shared.fetchCurrentUserFromFirebase { result in
                    switch result {
                    case.success(let userData):
                        if let userData = userData {
                            if let followings = userData.followings , let followingRequest = userData.followingsRequest {
                                if (followings.contains(uid)) || (followingRequest.contains(uid)) {
                                    self.unFollow()
                                    self.removeFollowRequest()
                                    self.folloBtn.setTitle("Follow", for: .normal)
                                    self.msgBtn.isHidden = true
                                    if isPrivate == "true"{
                                        self.isPrivateAccountBoard.isHidden = false
                                        self.makeLblsUserUnInteractable()
                                    }else{
                                        self.isPrivateAccountBoard.isHidden = true
                                        self.makeLblsUserInteractable()
                                    }
                                }else{
                                    if isPrivate == "false" {
                                        self.follow()
                                        self.folloBtn.setTitle("UnFollow", for: .normal)
                                        self.msgBtn.isHidden = false
                                        self.isPrivateAccountBoard.isHidden = true
                                        self.makeLblsUserInteractable()
                                    }else{
                                        self.followRequest()
                                        self.folloBtn.setTitle("Requested", for: .normal)
                                        self.isPrivateAccountBoard.isHidden = false
                                        self.makeLblsUserUnInteractable()
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
        if let currentUser = interactor?.currentUser , let  senderId = currentUser.uid , let receiverId = interactor?.user?.uid {
            StoreUserData.shared.saveUsersChatList(senderId: senderId, receiverId: receiverId) { _ in}
        }
        if let user = interactor?.user {
            let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            destinationVC.receiverUser = user
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func follow(){
        viewModel.saveFollower(uid: interactor?.user?.uid) { result  in
            switch result {
            case.success(let value):
                if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name) {
                    if let fmcToken = self.interactor?.user?.fcmToken {
                        PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Started following you.")
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func unFollow(){
        viewModel.removeFollower(uid: interactor?.user?.uid) { result in
            switch result {
            case.success(let value):
                print(value)
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func followRequest(){
        viewModel.requestFollower(uid: interactor?.user?.uid) { result  in
            switch result {
            case.success(let value):
                if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name) {
                    if let fmcToken = self.interactor?.user?.fcmToken {
                        PushNotification.shared.sendPushNotification(to: fmcToken, title: "Follow Request" , body: "\(name) requested to follow you.")
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func removeFollowRequest(){
        viewModel.removeFollowRequest(uid: interactor?.user?.uid) { result  in
            switch result {
            case.success(let value):
                print(value)
            case.failure(let error):
                print(error)
            }
        }
    }
    
}

extension UsersProfileView  : UsersProfileViewProtocol {
    
    func setUpMsgBtnAndFollowBtn() {
        self.msgBtn.isHidden = true
        if !(interactor?.isFollowAndMsgBtnShow!)!{
            folloBtn.isHidden = true
            msgBtn.isHidden = true
        }
    }
    
    func verifyIsPrivateOrNot() {
        if let user = interactor?.user , let isPrivate = interactor?.user?.isPrivate {
            if (isPrivate == "true") {
                isPrivateAccountBoard.isHidden = false
                makeLblsUserUnInteractable()
            }else{
                isPrivateAccountBoard.isHidden = true
                makeLblsUserInteractable()
            }
        }
    }
    
    func updateCell(flowLayout:UICollectionViewLayout){
        collectionViewOutlet.collectionViewLayout = flowLayout
    }
   
}


extension UsersProfileView: UICollectionViewDelegate, UICollectionViewDataSource , UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interactor?.allPost.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersProfileViewCell", for: indexPath) as! UsersProfileViewCell
        let cellData = interactor?.allPost[indexPath.row]
        if let imageURL = URL(string: cellData?.postImageURLs?[0] ?? "") {
            ImageLoader.loadImage(for: imageURL, into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        
        if let postCount = cellData?.postImageURLs?.count {
            cell.multiplePostIcon.isHidden = ( postCount > 1 ?  false : true )
        }
        
        cell.postImgPressed = { [weak self] in
            let storyboard = UIStoryboard.Common
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "PostPresentedView") as! PostPresentedView
            destinationVC.post = cellData
            destinationVC.modalPresentationStyle = .overFullScreen
            self?.present(destinationVC, animated: true, completion: nil)
        }
        
        return cell
    }
    
}


