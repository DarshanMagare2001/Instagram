//
//  ProfileVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import Kingfisher
import SkeletonView

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
    var viewModel1 = AuthenticationViewModel()
    var viewModel2 = ProfileViewModel()
    var allPost = [PostAllDataModel]()
    var currentUser : UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showAnimatedGradientSkeleton()
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingCountLabelTapped))
        followingsTxtLbl.isUserInteractionEnabled = true
        followingsTxtLbl.addGestureRecognizer(followingTapGesture)
        
        let followersTapGesture = UITapGestureRecognizer(target: self, action: #selector(followersCountLabelTapped))
        followersTxtLbl.isUserInteractionEnabled = true
        followersTxtLbl.addGestureRecognizer(followersTapGesture)
        
        let userImgTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserImg))
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(userImgTapGesture)
        
        configuration()
        updateUI()
    }
    
    
    @objc func didTapUserImg(){
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ProfilePresentedView") as! ProfilePresentedView
        destinationVC.user = currentUser
        destinationVC.modalPresentationStyle = .overFullScreen
        present(destinationVC, animated: true, completion: nil)
    }
    
    
    private func setBarItemsForProfileVC() {
        if let mainTabVC = tabBarController as? MainTabVC {
            if let name = FetchUserInfo.fetchUserInfoFromUserdefault(type: .name){
                DispatchQueue.main.async {
                    self.userName.text = name
                    mainTabVC.setBarItemsForProfileVC(profileName: name){
                        UIView.animate(withDuration: 0.5) {
                            self.sideMenuView.alpha = 1.0
                            self.sideMenuView.transform = CGAffineTransform(translationX: 0, y: 0)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data {
                    self.currentUser = data
                }
            case.failure(let error):
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.configuration()
            self.updateUI()
            self.setBarItemsForProfileVC()
        }
        self.photosCollectionView.isSkeletonable = true
        self.photosCollectionView.showAnimatedGradientSkeleton()
    }
    
    @objc func followingCountLabelTapped() {
        goToFollowerAndFollowing()
    }
    
    @objc func followersCountLabelTapped() {
        goToFollowerAndFollowing()
    }
    
    func goToFollowerAndFollowing(){
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    let storyboard = UIStoryboard.Common
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "FollowersAndFollowingVC") as! FollowersAndFollowingVC
                    destinationVC.user = user
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func sideMenuCloseBtnPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuView.alpha = 0.0
            self.sideMenuView.transform = CGAffineTransform(translationX: +self.sideMenuView.bounds.width, y: 0)
        }
    }
    
    
    @IBAction func editProfileBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "EditProfileVC"){ destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        Alert.shared.alertYesNo(title: "Log Out!", message: "Do you want to logOut?.", presentingViewController: self) { _ in
            MessageLoader.shared.showLoader(withText: "Logging out..")
            self.viewModel1.logout()
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                MessageLoader.shared.hideLoader()
                Navigator.shared.navigate(storyboard: UIStoryboard.Main, destinationVCIdentifier: "SignInVC"){ destinationVC in
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

extension ProfileVC {
    
    func configuration(){
        updateCell()
        updateSideMenu()
        initViewModel()
        eventObserver()
    }
    
    func initViewModel(){
        
    }
    
    func eventObserver(){
        
    }
    
    func updateCell() {
        // Configure the collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2 // Adjust the spacing between cells horizontally
        flowLayout.minimumLineSpacing = 2 // Adjust the spacing between cells vertically
        photosCollectionView.collectionViewLayout = flowLayout
    }
    
    func updateSideMenu(){
        self.sideMenuView.alpha = 0.0
        self.sideMenuView.transform = CGAffineTransform(translationX: +self.sideMenuView.bounds.width, y: 0)
    }
    
    func updateUI(){
        if let url = FetchUserInfo.fetchUserInfoFromUserdefault(type: .profileUrl) {
            if let imageURL = URL(string: url) {
                ImageLoader.loadImage(for: imageURL, into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            } else {
                print("Invalid URL: \(url)")
            }
        } else {
            print("URL is nil or empty")
        }
        
        if let bio = FetchUserInfo.fetchUserInfoFromUserdefault(type: .bio){
            self.userBio.text = bio
        }
        
        if let uid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) {
            PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                switch result {
                case .success(let images):
                    // Handle the images
                    print("Fetched images: \(images)")
                    
                    DispatchQueue.main.async{
                        self.allPost = images
                        self.postCountLbl.text = "\(self.allPost.count)"
                        self.photosCollectionView.stopSkeletonAnimation()
                        self.view.stopSkeletonAnimation()
                        self.photosCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                        self.photosCollectionView.reloadData()
                    }
                    
                case .failure(let error):
                    // Handle the error
                    print("Error fetching images: \(error)")
                }
            }
            
            FetchUserInfo.shared.fetchCurrentUserFromFirebase { [self] result in
                switch result {
                case .success(let userData):
                    if let userData = userData,let followers = userData.followers?.count,let followings = userData.followings?.count {
                        followersCountLbl.text = "\(followers)"
                        followingCountLbl.text = "\(followings)"
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        }
        
    }
    
    
}

extension ProfileVC:  SkeletonCollectionViewDataSource  , SkeletonCollectionViewDelegate , UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PhotosCell"
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! PhotosCell
        if let imageURL = URL(string: allPost[indexPath.row].postImageURL ?? "") {
            ImageLoader.loadImage(for: imageURL, into: cell.img, withPlaceholder: UIImage(systemName: "person.fill"))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            tapGesture.delegate = self
            cell.img.addGestureRecognizer(tapGesture)
            cell.img.isUserInteractionEnabled = true
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
