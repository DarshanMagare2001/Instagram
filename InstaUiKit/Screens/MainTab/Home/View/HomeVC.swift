//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SwiftUI
import FirebaseAuth

class HomeVC: UIViewController {
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var userImg: CircleImageView!
    var imgURL : URL?
    var userName : String?
    var allPost = [PostModel]()
    var allUniqueUsersArray = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    @IBAction func directMsgBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "DirectMsgVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
}

extension HomeVC {
    func updateUI(){
        Data.shared.getData(key: "ProfileUrl") { (result: Result<String?, Error>) in
            switch result {
            case .success(let urlString):
                if let url = urlString {
                    if let imageURL = URL(string: url) {
                        self.imgURL = imageURL
                    } else {
                        print("Invalid URL: \(url)")
                    }
                } else {
                    print("URL is nil or empty")
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
        
        Data.shared.getData(key: "Name") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.userName = data
            case .failure(let error):
                print(error)
            }
        }
        
        PostViewModel.shared.fetchAllPosts { result in
            switch result {
            case .success(let images):
                // Handle the images
                print("Fetched images: \(images)")
                DispatchQueue.main.async {
                    self.allPost = images
                    self.feedTableView.reloadData()
                    self.storiesCollectionView.reloadData()
                }
            case .failure(let error):
                // Handle the error
                print("Error fetching images: \(error)")
            }
        }
        
        if let url = imgURL {
            ImageLoader.loadImage(for: url, into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        
        FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    print(data)
                    self.allUniqueUsersArray = data
                    self.storiesCollectionView.reloadData()
                    self.feedTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let post = allPost[indexPath.row]
        DispatchQueue.main.async {
            ImageLoader.loadImage(for: URL(string: post.profileImageUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
            ImageLoader.loadImage(for: URL(string: post.profileImageUrl), into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
            ImageLoader.loadImage(for: URL(string: post.postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.postLocationLbl.text = post.location
            cell.postCaption.text = post.caption
            cell.userName.text = post.name
            cell.likeBtnTapped = { [weak self] in
                if let uid = Auth.auth().currentUser?.uid {
                    PostViewModel.shared.likePost(postDocumentID: post.postDocumentID, userUID: uid)
                }
            }
        }
        return cell
    }
}


extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allUniqueUsersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
        if let uid = allUniqueUsersArray[indexPath.row].uid,
           let name = allUniqueUsersArray[indexPath.row].name,
           let imgUrl = allUniqueUsersArray[indexPath.row].imageUrl{
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.userName.text = name
            }
        }
        return cell
    }
}


