//
//  MainTabVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

class MainTabVC: UITabBarController {
    private var postActionClosureForPostNxtBtn: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        if let viewControllers = viewControllers {
            viewControllers[0].title = "Home"
            viewControllers[1].title = "Search"
            viewControllers[2].title = "Post"
            viewControllers[3].title = "Likes"
            viewControllers[4].title = "Profile"
        }
    }
    
    func setBarItemsForHomeVC(){
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        let userProfileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileImageView.contentMode = .scaleToFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.image = UIImage(named: "InstaLogo")
        let userProfileView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileView.addSubview(userProfileImageView)
        let userProfileItem = UIBarButtonItem(customView: userProfileView)
        navigationItem.leftBarButtonItems = [userProfileItem]
    }
    
    func setBarItemsForSearchVC(){
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.title = "Search"
        navigationItem.leftBarButtonItems = nil
    }
    
    func setBarItemsForPostVC(action: @escaping () -> Void) {
        navigationItem.title = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.title = "Post"
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = nextButton
        self.postActionClosureForPostNxtBtn = action
    }
    @objc private func nextButtonTapped() {
        postActionClosureForPostNxtBtn?()
    }

    
    func setBarItemsForLikesVC(){
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.title = "Likes"
    }
    
    func setBarItemsForProfileVC(profileName:String){
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.title = profileName
    }
    
}
