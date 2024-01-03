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
    func setUpTapGestures()
    func setUpUI()
    func makeLblsUserInteractable()
    func makeLblsUserUnInteractable()
    func followBtnAction()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
    
    @IBAction func folloBtnPressed(_ sender: UIButton) {
        followBtnAction()
    }
    
    @IBAction func messageBtnPressed(_ sender: UIButton) {
        presenter?.saveUsersChatList()
        if let user = interactor?.user {
            presenter?.goToChatVC(user: user)
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
    
    func setUpTapGestures() {
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
    
    func setUpUI() {
        if let user = interactor?.user {
            if let uid = user.uid , let followers = user.followers?.count , let followings = user.followings?.count , let followersRequest = user.followersRequest {
                if (interactor?.isFollowAndMsgBtnShow!)!{
                    print(interactor?.currentUser)
                    if let userData = self.interactor?.currentUser , let currentUid = userData.uid {
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
                }
                
                if let count = self.interactor?.allPost.count{
                    self.totalPostCount.text = "\(count)"
                }
                totalFollowersCount.text = "\(followers)"
                totalFollowingCount.text = "\(followings)"
                self.collectionViewOutlet.reloadData()
                
            }
            
            if let imgUrl = user.imageUrl, let bio = user.bio  , let username = user.username {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                name.text = username
                userBio.text = bio
            }
            
        }
    }
    
    func followBtnAction() {
        if let user = interactor?.user {
            if let uid = user.uid , let isPrivate = user.isPrivate  {
                if let userData = interactor?.currentUser {
                    if let followings = userData.followings , let followingRequest = userData.followingsRequest {
                        if (followings.contains(uid)) || (followingRequest.contains(uid)) {
                            presenter?.unFollow()
                            presenter?.removeFollowRequest()
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
                                presenter?.follow()
                                self.folloBtn.setTitle("UnFollow", for: .normal)
                                self.msgBtn.isHidden = false
                                self.isPrivateAccountBoard.isHidden = true
                                self.makeLblsUserInteractable()
                            }else{
                                presenter?.followRequest()
                                self.folloBtn.setTitle("Requested", for: .normal)
                                self.isPrivateAccountBoard.isHidden = false
                                self.makeLblsUserUnInteractable()
                            }
                        }
                    }
                }
            }
        }
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
    
    @objc func postTextLblTapped(){
        if let allPost = interactor?.allPost {
            presenter?.goToFeedViewVC(allPost: allPost)
        }
    }
    
    @objc func followingsTextLblTapped() {
        goToFollowerAndFollowing()
    }
    
    @objc func followersTextLblTapped() {
        goToFollowerAndFollowing()
    }
    
    
    @objc func didTapUserImg() {
        if let user = interactor?.user {
            presenter?.goToProfilePresentedView(user: user)
        }
    }
    
    func goToFollowerAndFollowing(){
        if let user = interactor?.user {
            presenter?.goToFollowersAndFollowingVC(user: user)
        }
    }
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
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


