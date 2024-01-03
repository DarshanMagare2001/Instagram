//
//  LikesVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation

protocol LikesVCInteractorProtocol {
    var allPost : [PostAllDataModel] { get set }
    var currentUserUid: String? { get set }
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
}

class LikesVCInteractor {
    var allPost = [PostAllDataModel]()
    var currentUserUid: String?
}

extension LikesVCInteractor : LikesVCInteractorProtocol {
    func fetchPostDataOfPerticularUser(completion:@escaping()->()){
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
            self.currentUserUid = uid
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
