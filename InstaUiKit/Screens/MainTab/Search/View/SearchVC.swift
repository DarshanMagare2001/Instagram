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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCell()
        SearchVCViewModel.shared.fetchAllPostURL { value in
            if value{
                self.collectionViewOutlet.reloadData()
            }else{
                self.collectionViewOutlet.reloadData()
            }
        }
        
        HomeVCViewModel.shared.fetchUniqueUsers { value in
            if value{
                self.tableViewOutlet.reloadData()
            }else{
                self.tableViewOutlet.reloadData()
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
        return HomeVCViewModel.shared.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchVCTableViewCell", for: indexPath) as! SearchVCTableViewCell
        
        if let uid = HomeVCViewModel.shared.userArray[indexPath.row].keys.first,
           let name = HomeVCViewModel.shared.userArray[indexPath.row].values.first {
            DispatchQueue.main.async {
                EditProfileViewModel.shared.fetchUserProfileImageURLWithUid(uid: uid) { result in
                    switch result {
                    case .success(let url):
                        if let url = url {
                            print(url)
                            ImageLoader.loadImage(for: url, into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                            cell.name.text = name
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
