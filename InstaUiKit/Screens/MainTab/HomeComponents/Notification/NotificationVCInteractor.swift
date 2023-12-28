//
//  NotificationVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol NotificationVCInteractorProtocol {
    func fetchCurrentUser(completion:@escaping(Result<UserModel,Error>)->())
}

class NotificationVCInteractor {
    
}

extension NotificationVCInteractor : NotificationVCInteractorProtocol {
    
    func fetchCurrentUser(completion:@escaping(Result<UserModel,Error>)->()){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    completion(.success(user))
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
   
}
