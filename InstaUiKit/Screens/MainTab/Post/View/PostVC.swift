//
//  PostVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

class PostVC: UIViewController {
    @IBOutlet weak var imgForPost: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedImageIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        updateCell()
    }
    
}

extension PostVC {
    
    func configuration(){
        imgForPost.isHidden = true
        updateCell()
        initViewModel()
        eventObserver()
    }
    func initViewModel(){
        
    }
    func eventObserver(){
        
        
    }
    func updateCell() {
        // Configure the collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2 // Adjust the spacing between cells horizontally
        flowLayout.minimumLineSpacing = 2 // Adjust the spacing between cells vertically
        collectionView.collectionViewLayout = flowLayout
    }
    
    func updateSelectedImage(index: Int) {
        let imagesArray = PostViewModel.shared.imagesArray
        if index >= 0 && index < imagesArray.count {
            imgForPost.isHidden = false
            imgForPost.image = imagesArray[index]
        }
    }

}


extension PostVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PostViewModel.shared.imagesArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostVCCollectionCell", for: indexPath) as! PostVCCollectionCell
        let data = PostViewModel.shared.imagesArray
        cell.img.image = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageIndex = indexPath.row
        updateSelectedImage(index: indexPath.row)
    }
    
}
