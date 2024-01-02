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
    func fetchCurrentUserFromFirebase(completion:@escaping()->())
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
}

class UsersProfileViewInteractor {
    var allPost = [PostAllDataModel]()
    var user : UserModel?
    var currentUser : UserModel?
    var isFollowAndMsgBtnShow : Bool?
}

extension UsersProfileViewInteractor : UsersProfileViewInteractorProtocol {
    
    func fetchCurrentUserFromFirebase(completion:@escaping()->()){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    self.currentUser = user
                    completion()
                }
            case.failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func fetchPostDataOfPerticularUser(completion:@escaping()->()){
        if let uid = self.user?.uid {
            PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                switch result {
                case.success(let data):
                    self.allPost = data
                    completion()
                case.failure(let error):
                    print(error)
                    completion()
                }
            }
        }
    }
    
}
