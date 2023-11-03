//
//  SearchViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation

class SearchVCViewModel {
    static let shared = SearchVCViewModel()
    func fetchAllPostURL(completionHandler: @escaping (Result<[String?],Error>) -> Void) {
        PostViewModel.shared.fetchAllPosts { result in
            switch result {
            case .success(let images):
                // Handle the images
                print("Fetched images: \(images)")
                var postArray = [String?]()
                DispatchQueue.main.async {
                    for i in images {
                        if !postArray.contains(i.postImageURL) {
                            postArray.append(i.postImageURL)
                        }
                    }
                    completionHandler(.success(postArray))
                }
            case .failure(let error):
                // Handle the error
                print("Error fetching images: \(error)")
                completionHandler(.failure(error.localizedDescription as! Error))
            }
        }
    }
    
}

