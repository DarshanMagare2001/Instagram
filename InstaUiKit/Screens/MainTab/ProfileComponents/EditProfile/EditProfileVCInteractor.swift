//
//  EditProfileVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol EditProfileVCInteractorProtocol {
    var gender : String { get set }
    var countryCode: String { get set }
    var selectedImg : UIImage? { get set }
    var isPrivate : String { get set }
}

class EditProfileVCInteractor {
    var gender : String = ""
    var countryCode: String = "+91"
    var selectedImg : UIImage?
    var isPrivate : String = ""
}

extension EditProfileVCInteractor : EditProfileVCInteractorProtocol {
    
}
