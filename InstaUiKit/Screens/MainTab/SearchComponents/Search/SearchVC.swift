//
//  SearchVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol SearchVCProtocol : class {
    func setupCell()
    func setupRefreshcontrol()
    func setupUI(layout:UICollectionViewLayout)
    func addDoneButtonToSearchBarKeyboard() 
}


class SearchVC: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var collectionView: UIView!
    
    var presenter : SearchVCPresenterProtocol?
    var interactor : SearchVCInteractorProtocol?
    let disposeBag = DisposeBag()
    var collectionViewRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
}

extension SearchVC : SearchVCProtocol {
   
    func setupCell() {
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
    }
    
    func setupRefreshcontrol() {
        addDoneButtonToSearchBarKeyboard()
        collectionViewOutlet.addSubview(collectionViewRefreshControl)
        collectionViewRefreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
    }
    
    func setupUI(layout:UICollectionViewLayout) {
        updateTableView()
        updateCollectionView(layout: layout)
        self.collectionViewRefreshControl.endRefreshing()
    }
    
    @objc func refreshCollectionView() {
        self.presenter?.setupUI()
    }
    
    
    func addDoneButtonToSearchBarKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
}


extension SearchVC {
    func updateTableView() {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        // Create a BehaviorRelay to hold the filtered user data
        let filteredUsers = BehaviorRelay<[UserModel]>(value:  self.interactor?.allUniqueUsersArray ?? [])
        // Bind the filtered user data to the table view
        filteredUsers
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "FollowingCell", cellType: FollowingCell.self)) { (row, element, cell) in
                if let name = element.name , let userName = element.username , let imgUrl = element.imageUrl ,let uid = element.uid {
                    DispatchQueue.main.async {
                        ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        cell.nameLbl.text = name
                        cell.userNameLbl.text = userName
                        
                        if let user =  self.interactor?.currentUser, let followings = user.followings {
                            if followings.contains(uid) {
                                cell.followBtn.setTitle("Following", for: .normal)
                                cell.followBtn.setTitleColor(.black, for: .normal)
                                cell.followBtn.backgroundColor = .white
                            } else {
                                cell.followBtn.setTitle("Follow", for: .normal)
                                cell.followBtn.setTitleColor(.white, for: .normal)
                                cell.followBtn.backgroundColor = UIColor(named:"GlobalBlue")
                            }
                        }
                        
                        cell.followBtnTapped = { [weak self] in
                            let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
                            let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
                            destinationVC.user = element
                            destinationVC.isFollowAndMsgBtnShow = true
                            self?.navigationController?.pushViewController(destinationVC, animated: true)
                        }
                    }
                }
            }
                    .disposed(by: disposeBag)
        
        // Observe changes in the search bar text
        searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                // Filter the user data based on the search query
                let filteredData =  self?.interactor?.allUniqueUsersArray.filter { user in
                    if query.isEmpty {
                        // Show all users if the query is empty
                        self?.tableView.isHidden = true
                        self?.collectionView.isHidden = false
                        return true
                    } else {
                        // Filter users whose name contains the query
                        self?.tableView.isHidden = false
                        self?.collectionView.isHidden = true
                        return (user.name?.lowercased().contains(query.lowercased()) == true)
                    }
                }
                // Update the filteredUsers BehaviorRelay with the filtered data
                filteredUsers.accept(filteredData ?? [])
            })
            .disposed(by: disposeBag)
    }
}



extension SearchVC {
    func updateCollectionView(layout:UICollectionViewLayout) {
        collectionViewOutlet.dataSource = nil
        collectionViewOutlet.delegate = nil
        self.collectionViewOutlet.collectionViewLayout = layout
        
        Observable.just( self.interactor!.allPost)
            .do(onNext: { [weak self] _ in
                self?.collectionViewOutlet.reloadData()
            })
                .bind(to: collectionViewOutlet
                        .rx
                        .items(cellIdentifier: "SearchVCCollectionViewCell", cellType: SearchVCCollectionViewCell.self)) { (row, element, cell) in
                    if let element = element {
                        cell.configureCell(post: element)
                    }
                    cell.tapAction = { [weak self] in
                        if let data = element {
                            var tempData = [PostAllDataModel]()
                            tempData.append(data)
                            self?.handleCellTap(at: row, data: tempData)
                        }
                    }
                } .disposed(by: disposeBag)
    }
    
    func handleCellTap(at index: Int , data : [PostAllDataModel] ) {
        print(data)
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FeedViewVC") as! FeedViewVC
        destinationVC.allPost = data
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}


