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
    func saveUsersChatList()
    func follow()
    func unFollow()
    func followRequest()
    func removeFollowRequest()
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
    
    func saveUsersChatList(){
        if let currentUser = self.currentUser , let  senderId = currentUser.uid , let receiverId = self.user?.uid {
            StoreUserData.shared.saveUsersChatList(senderId: senderId, receiverId: receiverId) { _ in}
        }
    }
    
    func follow(){
        self.saveFollower(uid: self.user?.uid) { result  in
            switch result {
            case.success(let value):
                if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name) {
                    if let fmcToken = self.user?.fcmToken {
                        PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Started following you.")
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func unFollow(){
        self.removeFollower(uid:self.user?.uid) { _ in}
    }
    
    
    func followRequest(){
        self.requestFollower(uid: self.user?.uid) { result  in
            switch result {
            case.success(let value):
                if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name) {
                    if let fmcToken = self.user?.fcmToken {
                        PushNotification.shared.sendPushNotification(to: fmcToken, title: "Follow Request" , body: "\(name) requested to follow you.")
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func removeFollowRequest(){
        self.removeFollowRequest(uid: self.user?.uid) { _ in}
    }
    
    func saveFollower(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        if let whoFollowingsUid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserData.shared.saveFollowersToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    StoreUserData.shared.saveFollowingsToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                            completion(.success(true))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func removeFollower(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        if let whoFollowingsUid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserData.shared.removeFollowerFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    print(success)
                    StoreUserData.shared.removeFollowingFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                            completion(.success(true))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func requestFollower(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        if let whoFollowingsUid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserData.shared.saveFollowersRequestToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    StoreUserData.shared.saveFollowingsRequestToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                            completion(.success(true))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func removeFollowRequest(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        if let whoFollowingsUid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserData.shared.removeFollowerRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    StoreUserData.shared.removeFollowingRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                            completion(.success(true))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
            }
        }
    }
    
}
