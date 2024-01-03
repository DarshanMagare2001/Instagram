//
//  LikesVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol LikesVCRouterProtocol {
    
}

class LikesVCRouter {
    var viewController : UIViewController
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension LikesVCRouter : LikesVCRouterProtocol {
    
}
