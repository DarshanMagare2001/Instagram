//
//  EditProfileVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation

protocol EditProfileVCPresenterProtocol {
    func viewDidload()
}

class EditProfileVCPresenter {
    weak var view : EditProfileVCProtocol?
    var interactor : EditProfileVCInteractorProtocol
    init(view:EditProfileVCProtocol?,interactor:EditProfileVCInteractorProtocol){
        self.view = view
        self.interactor = interactor
    }
}

extension EditProfileVCPresenter : EditProfileVCPresenterProtocol {
    func viewDidload() {
        DispatchQueue.main.async {
            self.view?.setUpImagePicker()
            self.view?.setUpUserInfo()
        }
    }
}

