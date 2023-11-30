//
//  SwitchAccountVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import UIKit
import SkeletonView

class SwitchAccountVC: UIViewController {
    
    var viewModel = SwitchAccountViewModel()
    var cdUser : [CDUsersModel]?
    var user = [UserModel]()
    @IBOutlet weak var tableViewOutlet: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.isSkeletonable = true
        tableViewOutlet.showAnimatedGradientSkeleton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewOutlet.isSkeletonable = true
        tableViewOutlet.showAnimatedGradientSkeleton()
        if let cdUser = cdUser {
            viewModel.getUsers(cdUsers: cdUser) { data in
                DispatchQueue.main.async {
                    self.user = data
                    print(data)
                    self.tableViewOutlet.stopSkeletonAnimation()
                    self.view.stopSkeletonAnimation()
                    self.tableViewOutlet.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                    self.tableViewOutlet.reloadData()
                }
            }
        }
    }
    
}

extension SwitchAccountVC : SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "SwitchAccountCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchAccountCell", for: indexPath) as! SwitchAccountCell
        let data = user[indexPath.row]
        let imgUrl = data.imageUrl
        let name = data.name
        let userName = data.username
        DispatchQueue.main.async {
            ImageLoader.loadImage(for: URL(string:imgUrl ?? ""), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.name.text = name
            cell.userName.text = userName
        }
        return cell
    }
    
}
