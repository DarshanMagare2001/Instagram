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
    var viewModel1 = AuthenticationModel()
    var viewModel2 = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    override func viewWillAppear(_ animated: Bool) {
        configuration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configuration()
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
        updateUI()
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
        EditProfileViewModel.shared.fetchProfileFromUserDefaults { result in
            switch result {
            case.success(let profileData) :
                print(profileData)
                if let name = profileData.name {
                    if name != "" {
                        self.userName.text = "\(name)"
                        print(name)
                    }
                }
                
                if let bio = profileData.bio {
                    if bio != "" {
                        self.userBio.text = "\(bio)"
                        print(bio)
                    }
                }
                
                if let imageURL = profileData.imageURL, !imageURL.isEmpty {
                    ImageLoader.loadImage(for: URL(string: imageURL), into: self.userImg, withPlaceholder: UIImage(named: "person"))
                }
                
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! PhotosCell
        // Configure the cell here if necessary
        return cell
    }
}
