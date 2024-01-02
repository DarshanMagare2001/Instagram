//
//  SearchVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

protocol SearchVCPresenterProtocol {
    func viewDidload()
    func setupUI()
    func fetchAllPostURL(completion:@escaping()->())
    func fetchCurrentUserFromFirebase(completion:@escaping()->())
    func getCollectionViewLayout(completion:@escaping(UICollectionViewLayout)->())
}

class SearchVCPresenter {
    weak var view : SearchVCProtocol?
    var interactor : SearchVCInteractorProtocol
    var router : SearchVCRouterProtocol
    let dispatchGroup = DispatchGroup()
    init(view:SearchVCProtocol,interactor:SearchVCInteractorProtocol,router:SearchVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension SearchVCPresenter : SearchVCPresenterProtocol {
    
    func viewDidload() {
        view?.setupCell()
        view?.setupRefreshcontrol()
        setupUI()
    }
    
    func setupUI(){
        dispatchGroup.enter()
        fetchAllPostURL {
            self.dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchCurrentUserFromFirebase{
            self.dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async { [weak self] in
                self?.getCollectionViewLayout { layout in
                    self?.view?.setupUI(layout: layout)
                }
            }
        }
    }
    
    func fetchAllPostURL(completion:@escaping()->()){
        interactor.fetchAllPostURL { result in
            switch result {
            case.success(let data):
                print(data)
                self.interactor.allPost = data
                completion()
            case.failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func fetchCurrentUserFromFirebase(completion:@escaping()->()){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let user):
                if let user = user {
                    self.interactor.currentUser = user
                }
                FetchUserData.shared.fetchUniqueUsersFromFirebase { result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            print(data)
                            self.interactor.allUniqueUsersArray = data
                            completion()
                        }
                    case .failure(let error):
                        print(error)
                        completion()
                    }
                }
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func getCollectionViewLayout(completion:@escaping(UICollectionViewLayout)->()){
        interactor.getComposnalLayout { layout in
            completion(layout)
        }
    }
    
}
