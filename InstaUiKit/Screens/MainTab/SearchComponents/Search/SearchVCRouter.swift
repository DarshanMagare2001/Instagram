//
//  SearchVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

protocol SearchVCRouterProtocol {
    
}

class SearchVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
    
}

extension SearchVCRouter : SearchVCRouterProtocol {
    
}
