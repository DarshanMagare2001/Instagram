//
//  ProfileVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation

protocol ProfileVCInteractorProtocol {
    var allPost : [PostAllDataModel] { get set }
    var currentUser : UserModel? { get set }
    func fetchCurrentUserFromFirebase(completion:@escaping()->())
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
}

class ProfileVCInteractor {
    var allPost = [PostAllDataModel]()
    var currentUser : UserModel?
}

extension ProfileVCInteractor : ProfileVCInteractorProtocol {
    
    func fetchCurrentUserFromFirebase(completion:@escaping()->()){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data {
                    self.currentUser = data
                    completion()
                }
            case.failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func fetchPostDataOfPerticularUser(completion:@escaping()->()){
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
            PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                switch result {
                case .success(let images):
                    self.allPost = images
                    completion()
                case .failure(let error):
                    completion()
                    print("Error fetching images: \(error)")
                }
            }
        }
    }
    
}
