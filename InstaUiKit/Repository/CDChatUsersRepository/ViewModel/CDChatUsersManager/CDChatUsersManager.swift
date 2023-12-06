//
//  CDChatUsersManager.swift
//  InstaUiKit
//
//  Created by IPS-161 on 06/12/23.
//

import Foundation
import CoreData

class CDChatUsersManager {
    static let shared = CDChatUsersManager()
    private init(){}
    
    func createUser(user : CDChatUserModel , completion : @escaping (Bool) -> Void){
        let userContext = CDChatUsers(context: PersistantStorage.shared.persistentContainer.viewContext)
        userContext.id = user.id
        userContext.uid = user.uid
        PersistantStorage.shared.saveContext()
        completion(true)
    }
  
    func readUser() async throws -> [CDChatUserModel]? {
        var users = [CDChatUserModel]()
        do {
            let data = try PersistantStorage.shared.persistentContainer.viewContext.fetch(CDChatUsers.fetchRequest())
            for i in data {
                if let id = i.id,let uid = i.uid {
                    let user = CDChatUserModel(id: id, uid: uid)
                    users.append(user)
                }
            }
            print(users)
            return users
        } catch let error {
            print(error)
            throw error
        }
    }
    
}


