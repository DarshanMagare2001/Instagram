//
//  NotificationVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol NotificationVCPresenterProtocol {
    func viewDidload()
}

class NotificationVCPresenter {
    weak var view : NotificationVCProtocol?
    var interactor : NotificationVCInteractorProtocol
    init(view:NotificationVCProtocol,interactor:NotificationVCInteractorProtocol){
        self.view = view
        self.interactor = interactor
    }
}

extension NotificationVCPresenter : NotificationVCPresenterProtocol {
    func viewDidload(){
        
    }
}
