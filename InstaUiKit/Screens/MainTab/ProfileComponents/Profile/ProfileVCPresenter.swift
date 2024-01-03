//
//  ProfileVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit
import FirebaseAuth

protocol ProfileVCPresenterProtocol {
    func viewDidload()
    func viewWillAppear()
    func fetchUserData()
    func fetchCurrentUserFromFirebase(completion:@escaping()->())
    func fetchPostDataOfPerticularUser(completion:@escaping()->())
    func makeCollectionViewLayout() -> UICollectionViewLayout
    func logOut(view:UIViewController)
    func goToFeedViewVC(allPost:[PostAllDataModel])
    func goToProfilePresentedView(user:UserModel)
    func goToFollowersAndFollowingVC(user:UserModel)
    func goToPostPresentedView(post:PostAllDataModel)
    func goToEditProfileVC()
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
    }
    
    func viewWillAppear() {
        fetchUserData()
    }
    
    func fetchUserData(){
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
    
    func logOut(view:UIViewController){
        Alert.shared.alertYesNo(title: "Log Out!", message: "Do you want to logOut?.", presentingViewController: view) { _ in
            MessageLoader.shared.showLoader(withText: "Logging out..")
            do {
                try Auth.auth().signOut()
                print("Logout successful")
            } catch {
                print("Logout error: \(error.localizedDescription)")
            }
            DispatchQueue.main.asyncAfter(deadline:.now()+2){
                MessageLoader.shared.hideLoader()
                self.router.goToSignInVC()
            }
        } noHandler: { _ in
            print("No")
        }
    }
    
    func goToFeedViewVC(allPost: [PostAllDataModel]) {
        router.goToFeedViewVC(allPost:allPost)
    }
    
    func goToProfilePresentedView(user:UserModel){
        router.goToProfilePresentedView(user: user)
    }
    
    func goToFollowersAndFollowingVC(user:UserModel){
        router.goToFollowersAndFollowingVC(user:user)
    }
    
    func goToEditProfileVC(){
        router.goToEditProfileVC()
    }
    
    func goToPostPresentedView(post:PostAllDataModel){
        router.goToPostPresentedView(post: post)
    }
    
}
