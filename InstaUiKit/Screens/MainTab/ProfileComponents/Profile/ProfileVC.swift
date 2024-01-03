//
//  ProfileVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import Kingfisher
import SkeletonView
import FirebaseAuth

protocol ProfileVCProtocol : class {
    func setUpTapgestures()
    func setUpSideMenu()
    func startSkeleton()
    func stopSkeleton()
    func setUpUserInfo()
    func setUpCellsLayout(flowLayout:UICollectionViewLayout)
    func updatePhotosCollectionView()
    func sideBtnTapped()
    func goToFollowerAndFollowing()
}

class ProfileVC: UIViewController {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var postCountLbl: UILabel!
    @IBOutlet weak var followingsTxtLbl: UILabel!
    @IBOutlet weak var followersTxtLbl: UILabel!
    @IBOutlet weak var postTxtLbl: UILabel!
    
    var presenter : ProfileVCPresenterProtocol?
    var interactor : ProfileVCInteractorProtocol?
    var viewModel2 = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.viewWillAppear()
    }
    
    @IBAction func sideMenuCloseBtnPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuView.alpha = 0.0
            self.sideMenuView.transform = CGAffineTransform(translationX: +self.sideMenuView.bounds.width, y: 0)
        }
    }
    
    
    @IBAction func editProfileBtnPressed(_ sender: UIButton) {
        presenter?.goToEditProfileVC()
    }
    
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        Alert.shared.alertYesNo(title: "Log Out!", message: "Do you want to logOut?.", presentingViewController: self) { _ in
            MessageLoader.shared.showLoader(withText: "Logging out..")
            do {
                try Auth.auth().signOut()
                print("Logout successful")
            } catch {
                print("Logout error: \(error.localizedDescription)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                MessageLoader.shared.hideLoader()
                Navigator.shared.navigate(storyboard: UIStoryboard.Authentication, destinationVCIdentifier: "SignInVC"){ destinationVC in
                    if let destinationVC = destinationVC {
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }
        } noHandler: { _ in
            print("No")
        }
    }
    
    
}


extension ProfileVC : ProfileVCProtocol {
    
    func setUpTapgestures(){
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingCountLabelTapped))
        followingsTxtLbl.isUserInteractionEnabled = true
        followingsTxtLbl.addGestureRecognizer(followingTapGesture)
        
        let followersTapGesture = UITapGestureRecognizer(target: self, action: #selector(followersCountLabelTapped))
        followersTxtLbl.isUserInteractionEnabled = true
        followersTxtLbl.addGestureRecognizer(followersTapGesture)
        
        let userImgTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserImg))
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(userImgTapGesture)
        
        let postTxtLblTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPostTxtLbl))
        postTxtLbl.isUserInteractionEnabled = true
        postTxtLbl.addGestureRecognizer(postTxtLblTapGesture)
    }
    
    func setUpSideMenu(){
        self.sideMenuView.alpha = 0.0
        self.sideMenuView.transform = CGAffineTransform(translationX: +self.sideMenuView.bounds.width, y: 0)
    }
    
    func startSkeleton(){
        self.view.showAnimatedGradientSkeleton()
        self.photosCollectionView.isSkeletonable = true
        self.photosCollectionView.showAnimatedGradientSkeleton()
    }
    
    func stopSkeleton(){
        self.photosCollectionView.stopSkeletonAnimation()
        self.view.stopSkeletonAnimation()
        self.photosCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
    }
    
    func setUpUserInfo() {
        if let url = FetchUserData.fetchUserInfoFromUserdefault(type: .profileUrl) {
            if let imageURL = URL(string: url) {
                ImageLoader.loadImage(for: imageURL, into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            } else {
                print("Invalid URL: \(url)")
            }
        } else {
            print("URL is nil or empty")
        }
        
        if let bio = FetchUserData.fetchUserInfoFromUserdefault(type: .bio){
            self.userBio.text = bio
        }
        
        if let userName = FetchUserData.fetchUserInfoFromUserdefault(type: .userName){
            self.userName.text = userName
        }
        
        if let userData = interactor?.currentUser,let followers = userData.followers?.count,let followings = userData.followings?.count {
            followersCountLbl.text = "\(followers)"
            followingCountLbl.text = "\(followings)"
        }
        
        if let postCount = self.interactor?.allPost.count {
            self.postCountLbl.text = "\(postCount)"
        }
    }
    
    func setUpCellsLayout(flowLayout:UICollectionViewLayout){
        photosCollectionView.collectionViewLayout = flowLayout
    }
    
    func updatePhotosCollectionView() {
        stopSkeleton()
        photosCollectionView.reloadData()
    }
    
    func sideBtnTapped(){
        UIView.animate(withDuration: 0.5) {
            self.sideMenuView.alpha = 1.0
            self.sideMenuView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func goToFollowerAndFollowing(){
        if let currentUser = interactor?.currentUser{
            presenter?.goToFollowersAndFollowingVC(user:currentUser)
        }
    }
    
    @objc func didTapPostTxtLbl(){
        if let allPost = interactor?.allPost {
            presenter?.goToFeedViewVC(allPost:allPost)
        }
    }
    
    @objc func didTapUserImg(){
        if let currentUser = interactor?.currentUser {
            presenter?.goToProfilePresentedView(user: currentUser)
        }
    }
    
    @objc func followingCountLabelTapped() {
        goToFollowerAndFollowing()
    }
    
    @objc func followersCountLabelTapped() {
        goToFollowerAndFollowing()
    }
    
}


extension ProfileVC:  SkeletonCollectionViewDataSource  , SkeletonCollectionViewDelegate , UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interactor?.allPost.count ?? 0
    }
    
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PhotosCell"
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! PhotosCell
        let cellData = interactor?.allPost[indexPath.row]
        if let imageURL = URL(string: cellData?.postImageURLs?[0] ?? "") {
            ImageLoader.loadImage(for: imageURL, into: cell.img, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        
        if let postCount = cellData?.postImageURLs?.count {
            cell.multiplePostIcon.isHidden = ( postCount > 1 ?  false : true )
        }
        
        cell.imagePressed = { [weak self] in
            let storyboard = UIStoryboard.Common
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "PostPresentedView") as! PostPresentedView
            destinationVC.post = cellData
            destinationVC.modalPresentationStyle = .overFullScreen
            self?.present(destinationVC, animated: true, completion: nil)
        }
        return cell
    }
    
}


