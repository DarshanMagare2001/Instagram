//
//  UserModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import Foundation

struct ProfileModel: Codable {
    var uid: String?
    var name: String?
    var username: String?
    var bio: String?
    var phoneNumber: String?
    var gender: String?
    var imageURL: String?
    var countryCode : String?
    
    // Custom initializer to create ProfileModel from a dictionary
    init?(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String
        self.name = dictionary["name"] as? String
        self.username = dictionary["username"] as? String
        self.bio = dictionary["bio"] as? String
        self.phoneNumber = dictionary["phoneNumber"] as? String
        self.gender = dictionary["gender"] as? String
        self.imageURL = dictionary["imageURL"] as? String
        self.countryCode = dictionary["countryCode"] as? String
    }
}

struct UserData {
    let name: String
    let username: String
    let bio: String
    let countryCode: String
    let phoneNumber: String
    let gender: String
    // Add other properties as needed
}


