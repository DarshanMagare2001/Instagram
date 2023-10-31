//
//  HomeViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation

class HomeVCViewModel {
    static let shared = HomeVCViewModel()
    var userArray = [[String: String]]()
    
    func fetchUniqueUsers(completionHandler: @escaping (Bool) -> Void) {
        PostViewModel.shared.fetchAllPosts { result in
            switch result {
            case .success(let images):
                // Handle the images
                print("Fetched images: \(images)")
                DispatchQueue.main.async {
                    for post in images {
                        let uid = post.uid
                        let name = post.name
                        
                        // Check if the uid is not already in userArray
                        if !self.userArray.contains(where: { $0[uid] != nil }) {
                            self.userArray.append([uid: name])
                        }
                    }
                    completionHandler(true)
                }
            case .failure(let error):
                // Handle the error
                print("Error fetching images: \(error)")
                completionHandler(false)
            }
        }
    }
}

