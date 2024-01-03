//
//  PostVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol PostVCPresenterProtocol {
    func viewDidload()
    func goToUploadVC(img:[UIImage])
}

class PostVCPresenter {
    weak var view : PostVCProtocol?
    var router : PostVCRouterProtocol
    init(view : PostVCProtocol?,router : PostVCRouterProtocol){
        self.view = view
        self.router = router
    }
}

extension PostVCPresenter : PostVCPresenterProtocol {
    
    func viewDidload() {
        view?.presentImagePicker()
    }
    
    func goToUploadVC(img: [UIImage]) {
        router.goToUploadVC(img: img)
    }
    
}
