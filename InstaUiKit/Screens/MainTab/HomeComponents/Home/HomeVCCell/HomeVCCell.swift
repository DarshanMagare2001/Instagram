//
//  HomeVCCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/12/23.
//

import UIKit
import SkeletonView

class HomeVCCell: UITableViewCell {
    var allUniqueUsersArray : [UserModel]?
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    var addStoryBtnPressed : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewOutlet.delegate = self
        collectionViewOutlet.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension HomeVCCell: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return allUniqueUsersArray?.count ?? 0
        }
        return 0
    }
    
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStoryCell", for: indexPath) as! AddStoryCell
            if let url = FetchUserData.fetchUserInfoFromUserdefault(type: .profileUrl){
                cell.configureCell(imgUrl: url)
            }
            cell.addStoryBtnClosure = { [weak self] in
                self?.addStoryBtnPressed?()
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
            if let uid = allUniqueUsersArray?[indexPath.row].uid,
                let name = allUniqueUsersArray?[indexPath.row].name,
                let imgUrl = allUniqueUsersArray?[indexPath.row].imageUrl {
                DispatchQueue.main.async { [weak self] in
                    ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                    cell.userName.text = name
                }
            }
            return cell
        }

        // Default case: Return a default UICollectionViewCell with a reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
    }

    
}
