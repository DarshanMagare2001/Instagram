//
//  SearchVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

class SearchVC: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var tableViewOutlet: UITableView!
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchVCTableViewCell", for: indexPath) as! SearchVCTableViewCell
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
