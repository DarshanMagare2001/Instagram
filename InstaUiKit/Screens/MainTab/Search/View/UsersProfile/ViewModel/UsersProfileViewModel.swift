//
//  UsersProfileViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 24/11/23.
//

import Foundation

class UsersProfileViewModel {
    
    func saveFollower(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        if let whoFollowingsUid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserInfo.shared.saveFollowersToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    StoreUserInfo.shared.saveFollowingsToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
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
        if let whoFollowingsUid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserInfo.shared.removeFollowerFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    print(success)
                    StoreUserInfo.shared.removeFollowingFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
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
        if let whoFollowingsUid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserInfo.shared.saveFollowersRequestToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    StoreUserInfo.shared.saveFollowingsRequestToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
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
        if let whoFollowingsUid = FetchUserInfo.fetchUserInfoFromUserdefault(type: .uid) , let toFollowsUid = uid {
            StoreUserInfo.shared.removeFollowerRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case .success(let success):
                    StoreUserInfo.shared.removeFollowingRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
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
