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
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibLikes = UINib (nibName: "LikesCell", bundle: nil)
        let nibFollowing = UINib (nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nibLikes, forCellReuseIdentifier: "LikesCell")
        tableViewOutlet.register(nibFollowing, forCellReuseIdentifier: "FollowingCell")
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedSegmentIndex = segmentControllOutlet.selectedSegmentIndex
        
        if selectedSegmentIndex == 0 {
            let followingCell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! FollowingCell
            // Configure the FollowingCell with data based on indexPath or any other logic
            return followingCell
        } else {
            let likesCell = tableView.dequeueReusableCell(withIdentifier: "LikesCell", for: indexPath) as! LikesCell
            // Configure the LikesCell with data based on indexPath or any other logic
            return likesCell
        }
    }
    
}
