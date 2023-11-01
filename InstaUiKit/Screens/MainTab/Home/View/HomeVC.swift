//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SwiftUI

class HomeVC: UIViewController {
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var userImg: CircleImageView!
    var imgURL : URL?
    var userName : String?
    var allPost = [ImageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
        updateUI()
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
        
        HomeVCViewModel.shared.fetchUniqueUsers { value in
            if value{
                self.storiesCollectionView.reloadData()
            }else{
                self.storiesCollectionView.reloadData()
            }
        }
        
        feedTableView.reloadData()
        
    }
}

extension HomeVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let uid = allPost[indexPath.row].uid
        print(uid)
        DispatchQueue.main.async {
            EditProfileViewModel.shared.fetchUserProfileImageURLWithUid(uid: uid) { result in
                switch result{
                case.success(let url):
                    if let url = url {
                        print(url)
                        ImageLoader.loadImage(for: url, into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                        ImageLoader.loadImage(for: url, into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                        
                        ImageLoader.loadImage(for: URL(string: self.allPost[indexPath.row].imageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        
                        cell.postLocationLbl.text = self.allPost[indexPath.row].location
                        cell.postCaption.text = self.allPost[indexPath.row].caption
                        cell.userName.text = self.allPost[indexPath.row].name
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
        
        return cell
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HomeVCViewModel.shared.userArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
        
        if let uid = HomeVCViewModel.shared.userArray[indexPath.row].keys.first,
           let name = HomeVCViewModel.shared.userArray[indexPath.row].values.first {
            DispatchQueue.main.async {
                EditProfileViewModel.shared.fetchUserProfileImageURLWithUid(uid: uid) { result in
                    switch result {
                    case .success(let url):
                        if let url = url {
                            print(url)
                            ImageLoader.loadImage(for: url, into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                            cell.userName.text = name
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


