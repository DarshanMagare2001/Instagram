//
//  CommentsVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 08/11/23.
//

import UIKit
import SwiftUI

class CommentsVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var commentTxtFld: UITextField!
    var allPost : PostModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Data.shared.getData(key: "ProfileUrl") { (result:Result<String?,Error>) in
            switch result {
            case .success(let url):
                if let url = url {
                    ImageLoader.loadImage(for: URL(string: url), into: self.userImg , withPlaceholder: UIImage(systemName: "person.fill"))
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func postBtnPressed(_ sender: UIButton) {
        if let allPost = allPost , let comment = commentTxtFld.text {
            PostViewModel.shared.addCommentToPost(postDocumentID: allPost.postDocumentID, commentText: comment) { value in
                self.tableViewOutlet.reloadData()
            }
        }
    }
    
}

extension CommentsVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        return cell
    }
}
