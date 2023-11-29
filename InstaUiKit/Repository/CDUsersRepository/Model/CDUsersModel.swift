//
//  CDUsersModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import Foundation

struct CDUsersModel : Decodable {
    var id: UUID
    var name: String
    var userName: String
    var email: String
    var password: String
}
