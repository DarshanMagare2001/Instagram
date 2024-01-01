//
//  DirectMsgVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

protocol DirectMsgVCRouterProtocol {
    func goToAddChatVC(allUniqueUsersArray:[UserModel])
}

class DirectMsgVCRouter: passChatUserBack {
    
    
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
    
}

extension DirectMsgVCRouter : DirectMsgVCRouterProtocol {
    
    func goToAddChatVC(allUniqueUsersArray: [UserModel]) {
        let addChatVC = AddChatVCBuilder.build(allUniqueUsersArray: allUniqueUsersArray, delegate: self)
        viewController.navigationController?.present(addChatVC, animated: true, completion: nil)
    }
    
    func passChatUserBack(user: UserModel?) {
//        if let user = user {
//            if let userUid = user.uid {
//                MessageLoader.shared.showLoader(withText: "Adding Users")
//                if let currentUser = presenter?.currentUser , let  senderId = currentUser.uid , let receiverId = user.uid {
//                    StoreUserData.shared.saveUsersChatList(senderId: senderId, receiverId: receiverId) { result in
//                        switch result {
//                        case.success():
//                            self.presenter?.fetchAllChatUsersAndCurrentUser()
//                        case.failure(let error):
//                            print(error)
//                            MessageLoader.shared.hideLoader()
//                        }
//                    }
//                }
//            }
//        }
    }
    
}

