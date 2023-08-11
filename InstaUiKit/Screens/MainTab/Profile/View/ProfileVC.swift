//
//  ProfileVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import FirebaseAuth
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
        updateCell()
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        updateSideMenu()
        updateUserImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
        updateUserImage()
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
        let storyBoard: UIStoryboard = UIStoryboard(name: "MainTab", bundle: nil)
        let destinationVC = storyBoard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        viewModel1.logout()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(destinationVC, animated: true)
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
        updateUserImage()
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
                
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateUserImage(){
        guard let data  = ProfileViewModel.shared.userModel else {return}
        if let imageURLString = data.imageURL, let imageURL = URL(string: imageURLString) {
            self.userImg.kf.setImage(with: imageURL)
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
