//
//  SearchVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import RxSwift
import RxCocoa

class SearchVC: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var allPost = [ImageModel]()
    var allUniqueUsersArray = [UserModel]()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
        updateCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SearchVCViewModel.shared.fetchAllPostURL { value in
            if value{
                self.collectionViewOutlet.reloadData()
            }else{
                self.collectionViewOutlet.reloadData()
            }
        }
        
        FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    print(data)
                    self.allUniqueUsersArray = data
                    self.updateTableView()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateCell() {
        // Configure the collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2 // Adjust the spacing between cells horizontally
        flowLayout.minimumLineSpacing = 2 // Adjust the spacing between cells vertically
        collectionViewOutlet.collectionViewLayout = flowLayout
    }
    
}


extension SearchVC {
    func updateTableView() {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        let tableViewItems = Observable.just(allUniqueUsersArray)
        tableViewItems
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "FollowingCell", cellType: FollowingCell.self)) { (row, element, cell) in
                if let name = element.name , let userName = element.username , let imgUrl = element.imageUrl {
                    DispatchQueue.main.async {
                        ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        cell.nameLbl.text = name
                        cell.userNameLbl.text = userName
                    }
                }
            }.disposed(by: disposeBag)
    }
}


extension SearchVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SearchVCViewModel.shared.postArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchVCCollectionViewCell", for: indexPath) as! SearchVCCollectionViewCell
        DispatchQueue.main.async {
            if let url = SearchVCViewModel.shared.postArray[indexPath.row]{
                ImageLoader.loadImage(for: URL(string: url), into: cell.img, withPlaceholder: UIImage(systemName: "person.fill"))
            }
        }
        return cell
    }
    
}
