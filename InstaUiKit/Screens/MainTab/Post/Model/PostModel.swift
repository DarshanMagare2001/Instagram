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
    var name: String
    var uid: String
    var profileImageUrl: String
    var postDocumentID: String
    var likedBy: [String]
    var likesCount: Int
    var comments: [[String: Any]]
    var timestamp: Timestamp // Change to Timestamp

    init(
        postImageURL: String,
        caption: String,
        location: String,
        name: String,
        uid: String,
        profileImageUrl: String,
        postDocumentID: String,
        likedBy: [String],
        likesCount: Int,
        comments: [[String: Any]],
        timestamp: Timestamp // Change to Timestamp
    ) {
        self.postImageURL = postImageURL
        self.caption = caption
        self.location = location
        self.name = name
        self.uid = uid
        self.profileImageUrl = profileImageUrl
        self.postDocumentID = postDocumentID
        self.likedBy = likedBy
        self.likesCount = likesCount
        self.comments = comments
        self.timestamp = timestamp // Assign the provided Timestamp directly
    }
}
