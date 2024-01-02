//
//  UsersProfileViewInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation

protocol UsersProfileViewInteractorProtocol {
    var allPost : [PostAllDataModel] { get set }
    var user : UserModel? { get set }
    var currentUser : UserModel? { get set }
    var isFollowAndMsgBtnShow : Bool? { get set }
}

class UsersProfileViewInteractor {
    var allPost = [PostAllDataModel]()
    var user : UserModel?
    var currentUser : UserModel?
    var isFollowAndMsgBtnShow : Bool?
}

extension UsersProfileViewInteractor : UsersProfileViewInteractorProtocol {
    
}
