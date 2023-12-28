//
//  NotificationViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/12/23.
//

import Foundation
import UIKit

class NotificationViewModel {
    func acceptFollowRequest(toFollowsUid:String?,whoFollowingsUid:String? , completion:@escaping (Bool) -> Void ){
        if let toFollowsUid = toFollowsUid , let whoFollowingsUid = whoFollowingsUid {
            StoreUserData.shared.saveFollowersToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in
               completion(true)
            }
        }
    }
}
