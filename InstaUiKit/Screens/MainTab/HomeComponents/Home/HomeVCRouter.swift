//
//  HomeVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit


protocol HomeVCRouterProtocol {
    
}

class HomeVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
}

extension HomeVCRouter : HomeVCRouterProtocol {
    
}

