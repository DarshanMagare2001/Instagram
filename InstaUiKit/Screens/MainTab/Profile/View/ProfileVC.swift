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
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func updateUI() {
        guard let data: ProfileModel = viewModel2.userModel else { return }
        if let url = data.imageURL {
            userImg.kf.setImage(with: URL(string: url ))
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
