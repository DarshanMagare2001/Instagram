//
//  PostModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import FirebaseFirestore

struct PostModel {
    var postImageURL: String
    var caption: String
    var location: String
    var uid: String
    var postDocumentID: String
    var likedBy: [String]
    var likesCount: Int
    var comments: [[String: Any]]
    var timestamp: Timestamp 

    init(
        postImageURL: String,
        caption: String,
        location: String,
        uid: String,
        postDocumentID: String,
        likedBy: [String],
        likesCount: Int,
        comments: [[String: Any]],
        timestamp: Timestamp
    ) {
        self.postImageURL = postImageURL
        self.caption = caption
        self.location = location
        self.uid = uid
        self.postDocumentID = postDocumentID
        self.likedBy = likedBy
        self.likesCount = likesCount
        self.comments = comments
        self.timestamp = timestamp
    }
}
