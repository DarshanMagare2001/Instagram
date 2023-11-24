//
//  HomeViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation

class HomeVCViewModel {
    func fetchAllPostsOfFollowings(completion: @escaping (Result<[PostModel]?, Error>) -> Void) {
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let user):
                if let user = user, let followings = user.followings , let currentUserUid = user.uid {
                    var posts = [PostModel]()
                    PostViewModel.shared.fetchAllPosts { result in
                        switch result {
                        case .success(let fetchedPosts):
                            for post in fetchedPosts {
                                if followings.contains(post.uid) || currentUserUid == (post.uid) {
                                    posts.append(post)
                                }
                            }
                            completion(.success(posts))
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
}


