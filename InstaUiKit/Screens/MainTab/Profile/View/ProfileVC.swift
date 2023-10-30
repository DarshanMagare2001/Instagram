//
//  ProfileVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import Kingfisher

class ProfileVC: UIViewController {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBio: UILabel!
    var viewModel1 = AuthenticationViewModel()
    var viewModel2 = ProfileViewModel()
    var allPost = [ImageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        configuration()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configuration()
        updateUI()
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
        
        PostViewModel.shared.fetchImageData { result in
            switch result {
            case .success(let images):
                // Handle the images
                print("Fetched images: \(images)")
                DispatchQueue.main.async {
                    self.allPost = images
                    self.photosCollectionView.reloadData()
                }
            case .failure(let error):
                // Handle the error
                print("Error fetching images: \(error)")
            }
        }
        
    }
    
    
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! PhotosCell
        if let imageURL = URL(string: allPost[indexPath.row].imageURL) {
            ImageLoader.loadImage(for: imageURL, into: cell.img, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        return cell
    }
}
