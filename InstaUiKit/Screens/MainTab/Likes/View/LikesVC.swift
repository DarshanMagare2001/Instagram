//
//  LikesVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

class LikesVC: UIViewController {
    @IBOutlet weak var segmentControllOutlet: UISegmentedControl!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var allPost = [PostModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibLikes = UINib (nibName: "LikesCell", bundle: nil)
        let nibFollowing = UINib (nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nibLikes, forCellReuseIdentifier: "LikesCell")
        tableViewOutlet.register(nibFollowing, forCellReuseIdentifier: "FollowingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Data.shared.getData(key: "CurrentUserId") { (result:Result<String? , Error>) in
            switch result {
            case .success(let uid):
                if let uid = uid {
                    PostViewModel.shared.fetchPostDataOfPerticularUser(forUID: uid) { result in
                        switch result {
                        case .success(let images):
                            // Handle the images
                            print("Fetched images: \(images)")
                            DispatchQueue.main.async {
                                self.allPost = images
                                self.tableViewOutlet.reloadData()
                            }
                        case .failure(let error):
                            // Handle the error
                            print("Error fetching images: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func segmentControlDidChange(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = segmentControllOutlet.selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            searchBar.isHidden = false
        }else{
            searchBar.isHidden = true
        }
        tableViewOutlet.reloadData()
    }
    
    
}

extension LikesVC : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allPost.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < allPost.count {
            return allPost[section].likedBy.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedSegmentIndex = segmentControllOutlet.selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            let followingCell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! FollowingCell
            // Configure the FollowingCell with data based on indexPath or any other logic
            return followingCell
        } else {
            let likesCell = tableView.dequeueReusableCell(withIdentifier: "LikesCell", for: indexPath) as! LikesCell
            let section = indexPath.section
            let row = indexPath.row
            let uid = allPost[section].likedBy[indexPath.row]
            print(uid)
            if section < allPost.count && row < allPost[section].likedBy.count {
                DispatchQueue.main.async {
                    ProfileViewModel.shared.fetchUserData(uid: uid) { result in
                        switch result {
                        case.success(let data):
                            print(data)
                            if let imgUrl = data.imageUrl{
                                ImageLoader.loadImage(for: URL(string: imgUrl), into: likesCell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                            }
                        case.failure(let error):
                            print(error)
                        }
                    }
                    if let imageURL = URL(string: self.allPost[section].postImageURL) {
                        ImageLoader.loadImage(for: imageURL, into: likesCell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                    }
                }
            }
            return likesCell
        }
    }
    
    
}
