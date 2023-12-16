//
//  NotificationVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/11/23.
//

import UIKit

class NotificationVC: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var currentUser : UserModel?
    var viewModel = NotificationViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(){
        navigationItem.hidesBackButton = true
        navigationItem.title = "Notification"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    print(user)
                    self.currentUser = user
                    self.tableViewOutlet.reloadData()
                }
            case.failure(let error):
                print(error)
            }
        }
    }
   
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1  // Assuming you only have one section for follow requests
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Follow Requests"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser?.followersRequest?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        if let cellData = currentUser , let uid = cellData.followersRequest?[indexPath.row] {
            FetchUserInfo.shared.fetchUserDataByUid(uid:uid) { result in
                switch result {
                case.success(let user):
                    if let user = user , let imgUrl = user.imageUrl , let name = user.name {
                        cell.name.text = name
                        ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        
                        cell.acceptBtnBtnTapped = { [weak self] in
                            MessageLoader.shared.showLoader(withText: "Accepting..")
                            self?.viewModel.acceptFollowRequest(toFollowsUid: cellData.uid, whoFollowingsUid: uid){ bool in
                                if let toFollowsUid = cellData.uid {
                                    StoreUserInfo.shared.saveFollowingsToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { _ in
                                        self?.removeFollowRequest(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { bool in
                                            if let fmcToken = user.fcmToken , let name = cellData.name {
                                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "Request Accepted" , body: "\(name) Accepted your follow request.")
                                            }
                                            self?.fetchCurrentUser()
                                            MessageLoader.shared.hideLoader()
                                        }
                                    }
                                }
                            }
                        }
                        
                        cell.rejectBtnBtnBtnTapped = { [weak self] in
                            MessageLoader.shared.showLoader(withText: "Rejecting..")
                            if let toFollowsUid = cellData.uid {
                                self?.removeFollowRequest(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { bool in
                                    self?.fetchCurrentUser()
                                    MessageLoader.shared.hideLoader()
                                }
                            }
                        }
                        
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        if let cellData = currentUser , let uid = cellData.followersRequest?[indexPath.row] {
            FetchUserInfo.shared.fetchUserDataByUid(uid:uid) { result in
                switch result {
                case.success(let user):
                    if let user = user {
                        destinationVC.user = user
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func removeFollowRequest(toFollowsUid:String?,whoFollowingsUid:String?,completion:@escaping (Bool) -> Void){
        if let toFollowsUid = toFollowsUid , let whoFollowingsUid = whoFollowingsUid {
            StoreUserInfo.shared.removeFollowerRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case.success(let success):
                    StoreUserInfo.shared.removeFollowingRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in
                        completion(true)
                    }
                case.failure(let error):
                    print(error)
                    completion(false)
                }
            }
        }
    }
    
}
