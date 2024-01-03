//
//  ProfileVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol ProfileVCPresenterProtocol {
    func viewDidload()
    func fetchCurrentUserFromFirebase(completion:@escaping()->())
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
    func makeCollectionViewLayout() -> UICollectionViewLayout
}

class ProfileVCPresenter {
    weak var view : ProfileVCProtocol?
    var interactor : ProfileVCInteractorProtocol
    var router : ProfileVCRouterProtocol
    let dispatchGroup = DispatchGroup()
    init(view : ProfileVCProtocol?,interactor : ProfileVCInteractorProtocol,router : ProfileVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension ProfileVCPresenter : ProfileVCPresenterProtocol {
    
    func viewDidload() {
        view?.setUpTapgestures()
        view?.setUpSideMenu()
        view?.startSkeleton()
        view?.setUpCellsLayout(flowLayout:makeCollectionViewLayout())
        dispatchGroup.enter()
        fetchCurrentUserFromFirebase{
            self.dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchPostDataOfPerticularUser {
            self.dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.view?.setUpUserInfo()
                self.view?.updatePhotosCollectionView()
            }
        }
    }
    
    func fetchCurrentUserFromFirebase(completion:@escaping()->()){
        interactor.fetchCurrentUserFromFirebase {
            completion()
        }
    }
    
    func fetchPostDataOfPerticularUser(completion: @escaping () -> ()) {
        interactor.fetchPostDataOfPerticularUser {
            completion()
        }
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2 // Adjust the spacing between cells horizontally
        flowLayout.minimumLineSpacing = 2 // Adjust the spacing between cells vertically
        return flowLayout
    }
    
}
