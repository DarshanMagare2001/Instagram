//
//  SearchVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import RxSwift
import RxCocoa

class SearchVC: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var collectionView: UIView!
    var allUniqueUsersArray = [UserModel]()
    var allPostUrls = [String?]()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
        //        updateCell()
        getComposnalLayout()
        addDoneButtonToSearchBarKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SearchVCViewModel.shared.fetchAllPostURL { result in
            switch result {
            case.success(let data):
                print(data)
                self.allPostUrls = data
                self.updateCollectionView()
            case.failure(let error):
                print(error)
            }
        }
        
        FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    print(data)
                    self.allUniqueUsersArray = data
                    self.updateTableView()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getComposnalLayout(){
        
        //        Group 1
        
        let group1Item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.665), heightDimension: .fractionalHeight(1)))
        group1Item1.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let nestedGroup1Item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)))
        nestedGroup1Item1.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let nestedGroup1 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.335), heightDimension: .fractionalHeight(1)), subitems: [nestedGroup1Item1])
        
        
        let group1 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3)), subitems: [nestedGroup1,group1Item1])
        
        //        Group 2
        
        
        let nestedGroup2Item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)))
        nestedGroup1Item1.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let nestedGroup21 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.335), heightDimension: .fractionalHeight(1)), subitems: [nestedGroup1Item1])
        
        
        let nestedGroup2Item2 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)))
        nestedGroup2Item2.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let subGroupsItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1)))
        subGroupsItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let subGroupOf21 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)), subitems: [subGroupsItem])
        
        let subGroupOf22 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)), subitems: [subGroupsItem])
        
        
        let nestedGroup22 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.665), heightDimension: .fractionalHeight(1)), subitems: [subGroupOf21 , subGroupOf22 ])
        
        
        
        let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3)), subitems: [nestedGroup21 , nestedGroup22 ])
        
        let group3 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3)), subitems: [group1Item1 , nestedGroup1])
        
        
        let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(700)), subitems: [group1 , group2 , group3])
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        collectionViewOutlet.collectionViewLayout = layout
    }
    
    
    func updateCell() {
        // Configure the collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width / 3 - 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = 2 // Adjust the spacing between cells horizontally
        flowLayout.minimumLineSpacing = 2 // Adjust the spacing between cells vertically
        collectionViewOutlet.collectionViewLayout = flowLayout
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
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
    
    
}


extension SearchVC {
    func updateTableView() {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        // Create a BehaviorRelay to hold the filtered user data
        let filteredUsers = BehaviorRelay<[UserModel]>(value: allUniqueUsersArray)
        // Bind the filtered user data to the table view
        filteredUsers
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "FollowingCell", cellType: FollowingCell.self)) { (row, element, cell) in
                if let name = element.name , let userName = element.username , let imgUrl = element.imageUrl {
                    DispatchQueue.main.async {
                        ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        cell.nameLbl.text = name
                        cell.userNameLbl.text = userName
                        cell.followBtnTapped = { [weak self] in
                            let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
                            let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
                            //                            destinationVC.receiverUser = element
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
                let filteredData = self?.allUniqueUsersArray.filter { user in
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
    func updateCollectionView(){
        collectionViewOutlet.dataSource = nil
        collectionViewOutlet.delegate = nil
        let collectionViewItems = Observable.just(allPostUrls)
        collectionViewItems
            .bind(to: collectionViewOutlet
                    .rx
                    .items(cellIdentifier: "SearchVCCollectionViewCell" , cellType: SearchVCCollectionViewCell.self)) { (row, element, cell) in
                DispatchQueue.main.async {
                    if let url = element {
                        ImageLoader.loadImage(for: URL(string: url), into: cell.img, withPlaceholder: UIImage(systemName: "person.fill"))
                    }
                }
            }
                    .disposed(by: disposeBag)
    }
}
