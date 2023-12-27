//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SkeletonView
import RxSwift

class HomeVC: UIViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
    var allPost = [PostAllDataModel]()
    var allUniqueUsersArray = [UserModel]()
    var refreshControl = UIRefreshControl()
    var viewModel = HomeVCViewModel()
    let disPatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupRefreshControl()
        configureUI()
    }
    
    func directMsgBtnTapped(){
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "DirectMsgVC") {  destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    func notificationBtnTapped(){
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "NotificationVC") {  destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    private func configureTableView(){
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
        makeSkeletonable()
    }
    
    private func makeSkeletonable(){
        feedTableView.isSkeletonable = true
        feedTableView.showAnimatedGradientSkeleton()
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        feedTableView.addSubview(refreshControl)
    }
    
    @objc private func refresh() {
        self.makeSkeletonable()
        disPatchGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.updateUI()
            self?.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func configureUI() {
        updateUI()
    }
}

// MARK: - Update UI

extension HomeVC {
    func updateUI() {
        
        disPatchGroup.enter()
        DispatchQueue.main.async { [weak self] in
            self?.fetchData()
            self?.disPatchGroup.leave()
        }
        disPatchGroup.notify(queue: .main){}
    }
    
    private func fetchData() {
        viewModel.fetchAllPostsOfFollowings { result in
            if case .success(let posts) = result {
                if let posts = posts {
                    self.allPost = posts
                }
                DispatchQueue.main.async { [weak self] in
                    self?.feedTableView.stopSkeletonAnimation()
                    self?.view.stopSkeletonAnimation()
                    self?.feedTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                    self?.feedTableView.reloadData()
                }
            }
        }
        fetchUniqueUsers()
    }
    
    
    private func fetchUniqueUsers() {
        viewModel.fetchFollowingUsers { result in
            if case .success(let data) = result {
                if let data = data {
                    self.allUniqueUsersArray = data
                }
            }
        }
    }
    
}

extension HomeVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        if section == 1 {
            return allPost.count
        }
        return 0
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 11
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "HomeVCCell", for: indexPath) as! HomeVCCell
            cell2.allUniqueUsersArray = allUniqueUsersArray
            cell2.addStoryBtnPressed = { [weak self] in
                Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "AddStoryVC") { [weak self] destinationVC in
                    if let destinationVC = destinationVC {
                        self?.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }
            return cell2
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
            DispatchQueue.main.async { [weak self] in
                cell.configureCellData(post:self.allPost[indexPath.row], view: self)
            }
            return cell
        }
        return UITableViewCell()
    }
    
}



