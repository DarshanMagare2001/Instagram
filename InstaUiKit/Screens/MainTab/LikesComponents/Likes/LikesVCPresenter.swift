//
//  LikesVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation

protocol LikesVCPresenterProtocol {
    func viewDidload()
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
    func goToUsersProfileView(user:UserModel,isFollowAndMsgBtnShow:Bool)
}

class LikesVCPresenter {
    weak var view : LikesVCProtocol?
    var interactor : LikesVCInteractorProtocol
    var router : LikesVCRouterProtocol
    init(view : LikesVCProtocol? , interactor : LikesVCInteractorProtocol , router : LikesVCRouterProtocol ){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension LikesVCPresenter : LikesVCPresenterProtocol {
    
   func viewDidload() {
        view?.setUpCells()
        view?.setUpRefreshControl()
        view?.startSkeleton()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchPostDataOfPerticularUser{
                DispatchQueue.main.async {
                    self?.view?.reloadTableView()
                }
            }
        }
    }
    
    func fetchPostDataOfPerticularUser(completion: @escaping () -> ()){
        interactor.fetchPostDataOfPerticularUser {
            completion()
        }
    }
  
    func goToUsersProfileView(user: UserModel, isFollowAndMsgBtnShow: Bool) {
        router.goToUsersProfileView(user: user, isFollowAndMsgBtnShow: isFollowAndMsgBtnShow)
    }
    
}
