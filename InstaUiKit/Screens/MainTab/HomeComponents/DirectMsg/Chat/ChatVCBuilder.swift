//
//  ChatVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation
import UIKit

final class ChatVCBuilder {
    
    static var backButtonPressedClosure : (()->())?
    static var didTapUserViewClosure : (()->())?
    
    static func build(user:UserModel) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        let interactor = ChatVCInteractor()
        let router = ChatVCRouter(viewController: chatVC)
        let presenter = ChatVCPresenter(view: chatVC, interactor: interactor, router: router)
        chatVC.presenter = presenter
        chatVC.receiverUser = user
        
        chatVC.navigationItem.hidesBackButton = true
        
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserView))
        
        backButton.tintColor = .black
        chatVC.navigationItem.leftBarButtonItem = backButton
        
        ChatVCBuilder.backButtonPressedClosure = { [weak chatVC] in
            chatVC?.backButtonPressed()
        }
        
        ChatVCBuilder.didTapUserViewClosure = { [weak chatVC] in
            chatVC?.didTapUserView()
        }
        
        // User profile view
        let userProfileView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Reduced width to 120
        
        // Add user profile image view
        let userProfileImageView = UIImageView(frame: CGRect(x: -120, y: 0, width: 40, height: 40))
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.layer.cornerRadius = 20
        userProfileImageView.clipsToBounds = true
        if let imgUrl = user.imageUrl {
            userProfileImageView.sd_setImage(with: URL(string: imgUrl))
        }
        userProfileImageView.addGestureRecognizer(tapGesture)
        // Add user name label
        let userNameLabel = UILabel(frame: CGRect(x: -75, y: 0, width: 200, height: 44)) // Reduced width to 75
        userNameLabel.text = user.name
        userNameLabel.textColor = .black
        userNameLabel.font = UIFont.systemFont(ofSize: 16)
        userNameLabel.addGestureRecognizer(tapGesture)
        
        userProfileImageView.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true
        
        userProfileView.isUserInteractionEnabled = true
        userProfileView.addGestureRecognizer(tapGesture)
        
        // Add subviews to the custom view
        userProfileView.addSubview(userProfileImageView)
        userProfileView.addSubview(userNameLabel)
        
        // Set the custom view as the titleView of the navigation item
        chatVC.navigationItem.titleView = userProfileView
        
        return chatVC
    }
    
    @objc static func didTapUserView(){
        didTapUserViewClosure?()
    }
    
    @objc static func backButtonPressed() {
        backButtonPressedClosure?()
    }
    
}
