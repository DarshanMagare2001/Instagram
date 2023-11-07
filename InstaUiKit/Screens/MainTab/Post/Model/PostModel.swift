//
//  PostModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation

struct PostModel: Hashable {
    let postImageURL: String
    let caption: String
    let location: String
    let name: String
    let uid: String
    let profileImageUrl: String
    let postDocumentID : String
    
    init(postImageURL: String, caption: String, location: String, name: String, uid: String, profileImageUrl: String , postDocumentID : String) {
        self.postImageURL = postImageURL
        self.caption = caption
        self.location = location
        self.name = name
        self.uid = uid
        self.profileImageUrl = profileImageUrl
        self.postDocumentID = postDocumentID
    }
}

