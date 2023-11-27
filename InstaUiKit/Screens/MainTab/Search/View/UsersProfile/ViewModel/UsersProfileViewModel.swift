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
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func removeFollower(){
        
    }
}
