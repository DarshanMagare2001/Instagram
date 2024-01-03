//
//  UploadVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol UploadVCPresenterProtocol {
    func viewDidload()
    func uploadPost(view:UIViewController,caption:String?,location:String?)
}

class UploadVCPresenter {
    weak var view : UploadVCProtocol?
    var interactor : UploadVCInteractorProtocol
    init(view : UploadVCProtocol?,interactor : UploadVCInteractorProtocol){
        self.view = view
        self.interactor = interactor
    }
}

extension UploadVCPresenter : UploadVCPresenterProtocol {

    func viewDidload() {
        view?.setUpMultipleSignImg()
    }
    
    func uploadPost(view: UIViewController, caption: String?, location: String?) {
        interactor.uploadPost(view: view, caption: caption, location: location)
    }
    
}

