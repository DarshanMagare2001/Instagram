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
    @IBOutlet weak var sideMenueName: UILabel!
    @IBOutlet weak var headerName: UILabel!
    var viewModel1 = AuthenticationViewModel()
    var viewModel2 = ProfileViewModel()
    var allPost = [PostModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showAnimatedGradientSkeleton()
        configuration()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.configuration()
            self.updateUI()
        }
        self.photosCollectionView.isSkeletonable = true
        self.photosCollectionView.showAnimatedGradientSkeleton()
    }
    
    @IBAction func sideMenuBtnPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuView.alpha = 1.0
            self.sideMenuView.transform = CGAffineTransform(translationX: 0, y: 0)
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
        viewModel1.logout()
        Navigator.shared.navigate(storyboard: UIStoryboard.Main, destinationVCIdentifier: "SignInVC"){ destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
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
        Data.shared.getData(key: "ProfileUrl") { (result: Result<String?, Error>) in
            switch result {
            case .success(let urlString):
                if let url = urlString {
                    if let imageURL = URL(string: url) {
                        ImageLoader.loadImage(for: imageURL, into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                    } else {
                        print("Invalid URL: \(url)")
                    }
                } else {
                    print("URL is nil or empty")
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
        
        Data.shared.getData(key: "Name") { (result: Result<String, Error>) in
            switch result {
            case .success(let data):
                print(data)
                self.userName.text = data
                self.sideMenueName.text = data
                self.headerName.text = data
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "Bio") { (result: Result<String, Error>) in
            switch result {
            case .success(let data):
                print(data)
                self.userBio.text = data
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "CurrentUserId") { (result:Result<String? , Error>) in
            switch result {
            case .success(let uid):
                if let uid = uid {
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
            case .failure(let error):
                print(error)
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
        if let imageURL = URL(string: allPost[indexPath.row].postImageURL) {
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
