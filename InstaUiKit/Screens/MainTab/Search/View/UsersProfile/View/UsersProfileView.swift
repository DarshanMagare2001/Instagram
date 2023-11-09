//
//  UsersProfileView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/11/23.
//

import UIKit

class UsersProfileView: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    var allPost = [PostModel]()
    var user : UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = user {
            if let uid = user.uid {
                PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                    switch result {
                    case.success(let data):
                        self.allPost = data
                        self.collectionViewOutlet.reloadData()
                    case.failure(let error):
                        print(error)
                    }
                }
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
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension UsersProfileView: UICollectionViewDelegate, UICollectionViewDataSource , UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersProfileViewCell", for: indexPath) as! UsersProfileViewCell
        if let imageURL = URL(string: allPost[indexPath.row].postImageURL) {
            ImageLoader.loadImage(for: imageURL, into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            tapGesture.delegate = self
            cell.postImg.addGestureRecognizer(tapGesture)
            cell.postImg.isUserInteractionEnabled = true
        }
        return cell
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FeedViewVC") as! FeedViewVC
        destinationVC.allPost = allPost
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}
