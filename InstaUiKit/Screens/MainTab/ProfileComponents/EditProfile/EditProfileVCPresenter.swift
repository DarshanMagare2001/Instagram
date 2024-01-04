//
//  EditProfileVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol EditProfileVCPresenterProtocol {
    func viewDidload()
    func saveUserImageData(image:UIImage,completion:@escaping(Result<Bool,Error>)->())
    func saveUserImageToFirebase(image: UIImage , completion:@escaping(Result<String,Error>)->())
    func saveUserImageDataToCoreData(url:String,completion:@escaping()->())
    func saveUserProfileImageToFirebaseDatabase(imageUrl:String,completion:@escaping()->())
}

class EditProfileVCPresenter {
    weak var view : EditProfileVCProtocol?
    var interactor : EditProfileVCInteractorProtocol
    let dispatchGroup = DispatchGroup()
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
    
    func saveUserImageData(image:UIImage,completion:@escaping(Result<Bool,Error>)->()){
        
        DispatchQueue.global(qos: .background).async {
            self.saveUserImageToFirebase(image: image) { result in
                switch result {
                case.success(let url):
                    
                    self.dispatchGroup.enter()
                    self.saveUserImageDataToCoreData(url: url) {
                        self.dispatchGroup.leave()
                    }
                    
                    self.dispatchGroup.enter()
                    self.saveUserProfileImageToFirebaseDatabase(imageUrl: url) {
                        self.dispatchGroup.leave()
                    }
                    
                    self.dispatchGroup.notify(queue: .main) {
                        DispatchQueue.main.async {
                            completion(.success(true))
                        }
                    }
                    
                case.failure(let error):
                print(error)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        
    }
    
    
    func saveUserImageToFirebase(image: UIImage , completion:@escaping(Result<String,Error>)->()){
        interactor.saveUserImageToFirebase(image: image) { result in
            switch result {
            case.success(let url):
                print(url)
                completion(.success(url.absoluteString))
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func saveUserImageDataToCoreData(url:String,completion:@escaping()->()){
        Data.shared.saveData(url, key: "ProfileUrl") { _ in
            completion()
        }
    }
    
    func saveUserProfileImageToFirebaseDatabase(imageUrl:String,completion:@escaping()->()){
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
            interactor.saveUserProfileImageToFirebaseDatabase(uid: uid, imageUrl: imageUrl){ _ in
                completion()
            }
        }
    }
    
}

