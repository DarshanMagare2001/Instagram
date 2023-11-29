//
//  CDUserManager.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import Foundation
import CoreData

class CDUserManager {
    static let shared = CDUserManager()
    private init(){}
    
    func createUser(user : CDUsersModel , completion : @escaping (Bool) -> Void){
        let userContext = CDUsers(context: PersistantStorage.shared.persistentContainer.viewContext)
        userContext.id = user.id
          userContext.email = user.email
        userContext.password = user.password
        userContext.uid = user.uid
        PersistantStorage.shared.saveContext()
        completion(true)
    }
    
    func readUser(completion : @escaping (Result<[CDUsersModel]?,Error>) -> Void) {
        var users = [CDUsersModel]()
        do {
            let data = try PersistantStorage.shared.persistentContainer.viewContext.fetch(CDUsers.fetchRequest())
            for i in data {
                if let id = i.id, let email = i.email, let password = i.password , let uid = i.uid {
                    let user = CDUsersModel(id: id, email: email, password: password, uid: uid)
                    users.append(user)
                }
            }
            print(users)
            completion(.success(users))
        } catch let error {
            print(error)
            completion(.failure(error))
        }
    }
    
}
