//
//  ChatVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation
import UIKit

protocol ChatVCRouterProtocol {
    
}

class ChatVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
}

extension ChatVCRouter : ChatVCRouterProtocol {
    
}
