//
//  DirectMsgVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class DirectMsgVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    var allUniqueUsersArray = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
            switch result{
            case.success(let data):
                DispatchQueue.main.async {
                    self.allUniqueUsersArray = data
                    self.tableViewOutlet.reloadData()
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension DirectMsgVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUniqueUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectMsgCell", for: indexPath) as! DirectMsgCell
        if let uid = allUniqueUsersArray[indexPath.row].uid,
           let name = allUniqueUsersArray[indexPath.row].name,
           let userName = allUniqueUsersArray[indexPath.row].username {
            DispatchQueue.main.async {
                EditProfileViewModel.shared.fetchUserProfileImageURLWithUid(uid: uid) { result in
                    switch result {
                    case .success(let url):
                        if let url = url {
                            print(url)
                            ImageLoader.loadImage(for: url, into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                            cell.nameLbl.text = name
                            cell.userNameLbl.text = userName
                            cell.directMsgButtonTapped = { [weak self] in
                                Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "ChatVC") { destinationVC in
                                    if let destinationVC = destinationVC {
                                        self?.navigationController?.pushViewController(destinationVC, animated: true)
                                    }
                                }
                            }
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
