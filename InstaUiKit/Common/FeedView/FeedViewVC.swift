//
//  FeedViewVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/11/23.
//

import UIKit
import RxCocoa
import RxSwift

class FeedViewVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    var allPost : [PostModel]?
    init() {
        super.init(nibName: "FeedViewVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        tableViewOutlet.register(nib, forCellReuseIdentifier: "FeedCell")
    }
}

extension FeedViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = allPost?.count{
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        if let post = allPost?[indexPath.row] {
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: post.profileImageUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                ImageLoader.loadImage(for: URL(string: post.profileImageUrl), into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                ImageLoader.loadImage(for: URL(string: post.postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.postLocationLbl.text = post.location
                cell.postCaption.text = post.caption
                cell.userName.text = post.name
            }
        }
        return UITableViewCell()
    }
}
