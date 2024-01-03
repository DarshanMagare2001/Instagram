//
//  UsersProfileViewPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

protocol UsersProfileViewPresenterProtocol {
    func viewDidload()
    func setUpLayout()-> UICollectionViewLayout
    func fetchCurrentUserFromFirebase(completion:@escaping()->())
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
    func goToFeedViewVC(allPost: [PostAllDataModel])
    func goToProfilePresentedView(user:UserModel)
    func goToFollowersAndFollowingVC(user:UserModel)
}

class UsersProfileViewPresenter {
    weak var view : UsersProfileViewProtocol?
    var interactor : UsersProfileViewInteractorProtocol
    var router : UsersProfileViewRouterProtocol
    init(view:UsersProfileViewProtocol,interactor:UsersProfileViewInteractorProtocol,router:UsersProfileViewRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension UsersProfileViewPresenter : UsersProfileViewPresenterProtocol {
  
    func viewDidload() {
        view?.setUpMsgBtnAndFollowBtn()
        view?.verifyIsPrivateOrNot()
        view?.updateCell(flowLayout: setUpLayout())
        view?.setUpTapGestures()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchCurrentUserFromFirebase{
                self?.fetchPostDataOfPerticularUser{
                    DispatchQueue.main.async { [weak self] in
                        self?.view?.setUpUI()
                    }
                }
            }
        }
    }
    
    func setUpLayout() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        return flowLayout
    }
    
    func fetchCurrentUserFromFirebase(completion: @escaping () -> ()) {
        interactor.fetchCurrentUserFromFirebase {
            completion()
        }
    }
    
    func fetchPostDataOfPerticularUser(completion: @escaping () -> ()) {
        interactor.fetchPostDataOfPerticularUser {
            completion()
        }
    }
    
    func goToFeedViewVC(allPost: [PostAllDataModel]) {
        router.goToFeedViewVC(allPost: allPost)
    }
    
    func goToProfilePresentedView(user: UserModel) {
        router.goToProfilePresentedView(user: user)
    }
    
    func goToFollowersAndFollowingVC(user: UserModel) {
        router.goToFollowersAndFollowingVC(user: user)
    }
    
}
