//
//  FollowersAndFollowingVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/11/23.
//

import UIKit

class FollowersAndFollowingVC: UIViewController {
    @IBOutlet weak var segmentControlOutlet: UISegmentedControl!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var tableviewOutlet: UITableView!
    var user : UserModel?
    var segmentIndex : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableviewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func segmentControlPressed(_ sender: UISegmentedControl) {
        segmentIndex = sender.selectedSegmentIndex
        tableviewOutlet.reloadData()
    }
    
}

extension FollowersAndFollowingVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let user = user {
            if segmentIndex == 0 {
                return user.followers?.count ?? 0
            }else{
                return user.followings?.count ?? 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! FollowingCell
        cell.followBtn.isHidden = true
        if let user = user {
            
            if segmentIndex == 0 {
                if let followersUid = user.followers?[indexPath.row] {
                    FetchUserInfo.shared.fetchUserDataByUid(uid: followersUid) { result in
                        switch result {
                        case.success(let userData):
                            if let name = userData?.name , let userName = userData?.username , let imgUrl = userData?.imageUrl{
                                DispatchQueue.main.async {
                                    cell.nameLbl.text = name
                                    cell.userNameLbl.text = userName
                                    ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                                }
                            }
                        case.failure(let error):
                            print(error)
                        }
                    }
                }
                
                return cell
                
            }else{
                
                if let followersUid = user.followings?[indexPath.row] {
                    FetchUserInfo.shared.fetchUserDataByUid(uid: followersUid) { result in
                        switch result {
                        case.success(let userData):
                            if let name = userData?.name , let userName = userData?.username , let imgUrl = userData?.imageUrl{
                                DispatchQueue.main.async {
                                    cell.nameLbl.text = name
                                    cell.userNameLbl.text = userName
                                    ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                                }
                            }
                        case.failure(let error):
                            print(error)
                        }
                    }
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        if segmentIndex == 0 {
            if let user = user , let followersUid = user.followers?[indexPath.row] {
                FetchUserInfo.shared.fetchUserDataByUid(uid: followersUid) { result in
                    switch result {
                    case.success(let userData):
                        destinationVC.user = userData
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                        print(userData)
                    case.failure(let error):
                        print(error)
                    }
                }
            }
        }else{
            if let user = user , let followersUid = user.followings?[indexPath.row] {
                FetchUserInfo.shared.fetchUserDataByUid(uid: followersUid) { result in
                    switch result {
                    case.success(let userData):
                        destinationVC.user = userData
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                        print(userData)
                    case.failure(let error):
                        print(error)
                    }
                }
            }
        }
        
    }
    
}
