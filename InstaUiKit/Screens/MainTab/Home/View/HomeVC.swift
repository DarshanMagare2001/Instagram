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
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        feedTableView.reloadData()
        storiesCollectionView.reloadData()
        
        
        
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
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
        ImageLoader.loadImage(for: URL(string: allPost[indexPath.row].imageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
        
        cell.postLocationLbl.text = allPost[indexPath.row].location
        cell.postCaption.text = allPost[indexPath.row].caption
        cell.userName.text = allPost[indexPath.row].name
        return cell
    }
    
}

extension HomeVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
        if let url = imgURL {
            ImageLoader.loadImage(for: url, into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        if let name = userName {
            cell.userName
        }
        return cell
    }
}
