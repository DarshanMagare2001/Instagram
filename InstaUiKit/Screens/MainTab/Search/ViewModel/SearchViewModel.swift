//
//  SearchViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation

class SearchVCViewModel {
    static let shared = SearchVCViewModel()
    var postArray = [String?]()

    func fetchAllPostURL(completionHandler: @escaping (Bool) -> Void) {
        PostViewModel.shared.fetchAllPosts { result in
            switch result {
            case .success(let images):
                // Handle the images
                print("Fetched images: \(images)")
                DispatchQueue.main.async {
                    for i in images {
                        if !self.postArray.contains(i.imageURL) {
                            self.postArray.append(i.imageURL)
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

