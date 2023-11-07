//
//  FeedViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/11/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class FeedViewModel {
    static let shared = FeedViewModel()
    private init() {}
    
    let db = Firestore.firestore()
    
    // Function to like a post
    func likePost(postUID: String, userUID: String) {
        let postRef = db.collection("posts").document(postUID)
        
        postRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document, document.exists else {
                return
            }
            
            var postData = document.data()
            
            if var likesArray = postData?["likes"] as? [String] {
                if !likesArray.contains(userUID) {
                    likesArray.append(userUID)
                    postData?["likes"] = likesArray
                    postRef.setData(postData ?? [:])
                }
            } else {
                postData?["likes"] = [userUID]
                postRef.setData(postData ?? [:])
            }
        }
    }

    // Function to unlike a post
    func unlikePost(postUID: String, userUID: String) {
        let postRef = db.collection("posts").document(postUID)
        
        postRef.getDocument { [weak self] document, error in
            guard let self = self, let document = document, document.exists else {
                return
            }
            
            var postData = document.data()
            
            if var likesArray = postData?["likes"] as? [String], let index = likesArray.firstIndex(of: userUID) {
                likesArray.remove(at: index)
                postData?["likes"] = likesArray
                postRef.setData(postData ?? [:])
            }
        }
    }
}
