//
//  ProfileVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol ProfileVCRouterProtocol {
    
}

class ProfileVCRouter {
    var viewController : UIViewController
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension ProfileVCRouter : ProfileVCRouterProtocol {
    
}
