//
//  MainTabVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

typealias Tabs = (
    home:UIViewController,
    search:UIViewController,
    post:UIViewController,
    likes:UIViewController,
    profile:UIViewController
)


class MainTabVC: UITabBarController {
    private var postActionClosureForsideBtnTappedForProfileVC: (() -> Void)?
    private var postActionClosureForDirectMsgBtnForHomeVC: (() -> Void)?
    private var postActionClosureForNotificationBtnForHomeVC: (() -> Void)?
    typealias BarButtonAction = (_ buttonType: BarButtonTypeForHomeVC) -> Void
    
    init(tabs:Tabs){
        super.init(nibName: nil, bundle: nil)
        viewControllers = [tabs.home,tabs.search,tabs.post,tabs.likes,tabs.profile]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    enum BarButtonTypeForHomeVC {
        case directMessage
        case notification
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setBarItemsForHomeVC(isdirectMsgHaveNotification: Bool, isNotificationBtnHaveNotification: Bool, notificationCountForDirectMsg: Int, notificationCountForNotificationBtn: Int, action: @escaping BarButtonAction) {
        
        var barButtonItems: [UIBarButtonItem] = []
        
        if isdirectMsgHaveNotification {
            let directMsgBtn = createCircularButtonWithLabel(image: UIImage(systemName: "paperplane"), action: #selector(directMsgBtnTapped), count: notificationCountForDirectMsg)
            barButtonItems.append(directMsgBtn)
        } else {
            let directMsgBtn = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(directMsgBtnTapped))
            directMsgBtn.tintColor = UIColor.black
            barButtonItems.append(directMsgBtn)
        }
        
        if isNotificationBtnHaveNotification {
            let notificationBtn = createCircularButtonWithLabel(image: UIImage(systemName: "bell"), action: #selector(notificationBtnTapped), count: notificationCountForNotificationBtn)
            barButtonItems.append(notificationBtn)
        } else {
            let notificationBtn = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(notificationBtnTapped))
            notificationBtn.tintColor = UIColor.black
            barButtonItems.append(notificationBtn)
        }
        
        navigationItem.rightBarButtonItems = barButtonItems
        
        self.postActionClosureForDirectMsgBtnForHomeVC = { action(.directMessage) }
        self.postActionClosureForNotificationBtnForHomeVC = { action(.notification) }
    }
    
    
    func createCircularButtonWithLabel(image: UIImage?, action: Selector, count: Int) -> UIBarButtonItem {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action: action, for: .touchUpInside)
        
        let label = UILabel(frame: CGRect(x: 20, y: -8, width: 20, height: 20))
        label.backgroundColor = .red
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = label.frame.width / 2
        label.text = "\(count)"
        
        container.addSubview(button)
        container.addSubview(label)
        
        // Add Auto Layout constraints to position the button and label within the container
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.widthAnchor.constraint(equalTo: container.widthAnchor),
            button.heightAnchor.constraint(equalTo: container.heightAnchor),
            
            label.widthAnchor.constraint(equalToConstant: 20),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        return UIBarButtonItem(customView: container)
    }
    
    @objc func directMsgBtnTapped(){
        postActionClosureForDirectMsgBtnForHomeVC?()
    }
    
    @objc func notificationBtnTapped() {
        postActionClosureForNotificationBtnForHomeVC?()
    }
    
    func setBarItemsForSearchVC(){
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.title = "Search"
    }
    
    func setBarItemsForLikesVC(){
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.title = "Likes"
    }
    
    func setBarItemsForProfileVC(profileName: String, action: @escaping () -> Void) {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.rightBarButtonItems = nil
        if let nextButtonImage = UIImage(systemName: "line.3.horizontal")?.withRenderingMode(.alwaysOriginal) {
            let sideBtn = UIBarButtonItem(image: nextButtonImage, style: .plain, target: self, action: #selector(sideBtnTapped))
            navigationItem.rightBarButtonItem = sideBtn
            self.postActionClosureForsideBtnTappedForProfileVC = action
        }
        navigationItem.title = profileName
    }
    
    
    @objc private func sideBtnTapped() {
        postActionClosureForsideBtnTappedForProfileVC?()
    }
    
}
