//
//  SearchVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation

protocol SearchVCInteractorProtocol {
    var allUniqueUsersArray : [UserModel] { get set }
    var allPost : [PostAllDataModel?] { get set }
    var currentUser : UserModel? { get set }
}

class SearchVCInteractor {
    var allUniqueUsersArray = [UserModel]()
    var allPost = [PostAllDataModel?]()
    var currentUser : UserModel?
}

extension SearchVCInteractor : SearchVCInteractorProtocol {
    
}
