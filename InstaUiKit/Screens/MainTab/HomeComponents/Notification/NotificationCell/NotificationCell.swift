//
//  NotificationCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/12/23.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var acceptBtn: RoundedButton!
    @IBOutlet weak var rejectBtn: RoundedButton!
    var acceptBtnBtnTapped: (() -> Void)?
    var rejectBtnBtnBtnTapped: (() -> Void)?
    var viewModel = NotificationViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptBtnPressed(_ sender: UIButton) {
        acceptBtnBtnTapped?()
    }
    
    
    @IBAction func rejectBtnPressed(_ sender: UIButton) {
        rejectBtnBtnBtnTapped?()
    }
    
    func configureCell(currentUser:UserModel? , indexPath : Int ){
        if let cellData = currentUser , let uid = cellData.followersRequest?[indexPath] {
            FetchUserData.shared.fetchUserDataByUid(uid:uid) { result in
                switch result {
                case.success(let user):
                    if let user = user , let imgUrl = user.imageUrl , let name = user.name {
                        self.name.text = name
                        ImageLoader.loadImage(for: URL(string:imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        
                        self.acceptBtnBtnTapped = { [weak self] in
                            MessageLoader.shared.showLoader(withText: "Accepting..")
                            self?.viewModel.acceptFollowRequest(toFollowsUid: cellData.uid, whoFollowingsUid: uid){ bool in
                                if let toFollowsUid = cellData.uid {
                                    StoreUserData.shared.saveFollowingsToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { _ in
                                        self?.removeFollowRequest(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { bool in
                                            if let fmcToken = user.fcmToken , let name = cellData.name {
                                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "Request Accepted" , body: "\(name) Accepted your follow request.")
                                            }
//                                            self?.fetchCurrentUser()
                                            MessageLoader.shared.hideLoader()
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.rejectBtnBtnBtnTapped = { [weak self] in
                            MessageLoader.shared.showLoader(withText: "Rejecting..")
                            if let toFollowsUid = cellData.uid {
                                self?.removeFollowRequest(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { bool in
//                                    self?.fetchCurrentUser()
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
    }
    
    func removeFollowRequest(toFollowsUid:String?,whoFollowingsUid:String?,completion:@escaping (Bool) -> Void){
        if let toFollowsUid = toFollowsUid , let whoFollowingsUid = whoFollowingsUid {
            StoreUserData.shared.removeFollowerRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case.success(let success):
                    StoreUserData.shared.removeFollowingRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in
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
