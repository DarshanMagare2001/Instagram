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
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
        updateCell()
        SearchVCViewModel.shared.fetchAllPostURL { value in
            if value{
                self.collectionViewOutlet.reloadData()
            }else{
                self.collectionViewOutlet.reloadData()
            }
        }
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
                    self.tableViewOutlet.reloadData()
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

extension SearchVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUniqueUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! FollowingCell
        
        if let uid = allUniqueUsersArray[indexPath.row].uid,
           let name = allUniqueUsersArray[indexPath.row].name,
           let userName = allUniqueUsersArray[indexPath.row].username {
            DispatchQueue.main.async {
                EditProfileViewModel.shared.fetchUserProfileImageURLWithUid(uid: uid) { result in
                    switch result {
                    case .success(let url):
                        if let url = url {
                            print(url)
                            ImageLoader.loadImage(for: url, into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                            cell.nameLbl.text = name
                            cell.userNameLbl.text = userName
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        
        return cell
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
