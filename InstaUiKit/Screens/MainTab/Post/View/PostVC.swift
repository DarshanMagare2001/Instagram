//
//  PostVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

class PostVC: UIViewController {
    @IBOutlet weak var imgForPost: UIImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var imageView: UIView!
    var selectedImageIndex: Int?
    var selectedImageIndices = Set<Int>()
    var currentlySelectedImageIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        updateCell()
    }
    
    @IBAction func nxtBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "UploadVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    
}

extension PostVC {
    
    func configuration(){
        imageView.isHidden = true
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
            imageView.isHidden = false
            imgForPost.image = imagesArray[index]
            selectedImageIndex = index // Update the selected image index
        }
    }
    
}


extension PostVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PostViewModel.shared.imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostVCCollectionCell", for: indexPath) as! PostVCCollectionCell
        let data = PostViewModel.shared.imagesArray
        cell.img.image = data[indexPath.row]
        
        if indexPath.row == currentlySelectedImageIndex {
            // Show the checkmark image for the currently selected image
            cell.checkMarkImg.isHidden = false
        } else {
            // Hide the checkmark image for other images
            cell.checkMarkImg.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect the previously selected image, if any
        if let selectedImageIndex = currentlySelectedImageIndex {
            selectedImageIndices.remove(selectedImageIndex)
        }
        currentlySelectedImageIndex = indexPath.row
        updateSelectedImage(index: indexPath.row)
        // Reload the cells to update the checkmark image visibility
        collectionView.reloadData()
    }
    
}
