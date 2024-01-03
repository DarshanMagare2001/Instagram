//
//  PostVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol PostVCRouterProtocol {
    func goToUploadVC(img:[UIImage])
}

class PostVCRouter {
    var viewController : UIViewController
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension PostVCRouter : PostVCRouterProtocol {
    func goToUploadVC(img: [UIImage]) {
        let uploadVC = UploadVCBuilder.build(img:img)
        viewController.navigationController?.pushViewController(uploadVC, animated: true)
    }
}
