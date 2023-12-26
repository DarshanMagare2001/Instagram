//
//  SwitchAccountViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/11/23.
//

import Foundation

class SwitchAccountViewModel {
    
    func getUsers(cdUsers: [CDUsersModel], completion: @escaping ([UserModel]) -> Void) {
        var users = [UserModel]()
        let dispatchGroup = DispatchGroup()
        for i in cdUsers {
            print(i.uid)
            dispatchGroup.enter()
            FetchUserData.shared.fetchUserDataByUid(uid: i.uid) { result in
                switch result {
                case .success(let user):
                    if let user = user {
                        print(user)
                        users.append(user)
                    }
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(users)
        }
    }

    
}
