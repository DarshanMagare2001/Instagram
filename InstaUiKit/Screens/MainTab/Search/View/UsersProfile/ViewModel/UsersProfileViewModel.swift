//
//  UsersProfileViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 24/11/23.
//

import Foundation

class UsersProfileViewModel {
    
    func saveFollower(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        Data.shared.getData(key: "CurrentUserId") { (result:Result<String?,Error>) in
            switch result {
            case .success(let whoFollowingsUid):
                if let whoFollowingsUid = whoFollowingsUid , let toFollowsUid = uid {
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
                    
                    StoreUserInfo.shared.saveFollowersRequestToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in
                        StoreUserInfo.shared.saveFollowingsRequestToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in}
                    }
                    
                    
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func removeFollower(uid : String? , completion : @escaping (Result<Bool,Error>) -> Void){
        Data.shared.getData(key: "CurrentUserId") { (result:Result<String?,Error>) in
            switch result {
            case .success(let whoFollowingsUid):
                if let whoFollowingsUid = whoFollowingsUid , let toFollowsUid = uid {
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
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
}
