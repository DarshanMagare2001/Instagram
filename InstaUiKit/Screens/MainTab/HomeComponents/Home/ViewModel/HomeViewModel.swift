//
//  HomeViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation
import UIKit

class HomeVCViewModel {
    
    func fetchAllPostsOfFollowings(completion: @escaping (Result<[PostAllDataModel]?, Error>) -> Void) {
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let user):
                if let user = user, let followings = user.followings , let currentUserUid = user.uid {
                    var posts = [PostAllDataModel]()
                    PostViewModel.shared.fetchAllPosts { result in
                        switch result {
                        case .success(let fetchedPosts):
                            for post in fetchedPosts {
                                if let uid = post.uid {
                                    if followings.contains(uid) || currentUserUid == (uid) {
                                        posts.append(post)
                                    }
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
    
    func fetchFollowingUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user, let followings = user.followings {
                    var users = [UserModel]()
                    FetchUserData.shared.fetchUniqueUsersFromFirebase { result in
                        switch result {
                        case .success(let fetchedUsers):
                            for user in fetchedUsers {
                                if let uid = user.uid {
                                    if followings.contains(uid){
                                        users.append(user)
                                    }
                                }
                            }
                            completion(.success(users))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func fetchAllNotifications(completion:@escaping (Result<Int , Error>) -> Void){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    completion(.success(user.followersRequest?.count ?? 0))
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func fetchUserChatNotificationCount(completion:@escaping (Result<Int?,Error>) -> Void){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user , let notification = user.usersChatNotification {
                    completion(.success(notification.count))
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func likePost(postPostDocumentID:String,
                  uid:String,
                  postUid:String,
                  cell:FeedCell){
        PostViewModel.shared.likePost(postDocumentID: postPostDocumentID, userUID: uid) { [weak self] success in
            if success {
                // Update the UI: Set the correct image for the like button
                cell.isLiked = true
                let imageName = cell.isLiked ? "heart.fill" : "heart"
                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                FetchUserData.shared.fetchUserDataByUid(uid: postUid) { [weak self] result in
                    switch result {
                    case.success(let data):
                        if let data = data , let fmcToken = data.fcmToken {
                            if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name) {
                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Liked your post.")
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
                
            }
        }
    }
    
    func unLikePost(postPostDocumentID:String,
                    uid:String,
                    cell:FeedCell){
        PostViewModel.shared.unlikePost(postDocumentID: postPostDocumentID, userUID: uid) { success in
            if success {
                // Update the UI: Set the correct image for the like button
                cell.isLiked = false
                let imageName = cell.isLiked ? "heart.fill" : "heart"
                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
            }
        }
    }
    
}


