//
//  PostModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation

struct ImageModel {
    let imageURL: String
    let caption: String
    let location: String
    let uid: String

    init(imageURL: String, caption: String, location: String, uid: String) {
        self.imageURL = imageURL
        self.caption = caption
        self.location = location
        self.uid = uid
    }
}
