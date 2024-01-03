//
//  EditProfileVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit
import ADCountryPicker
import YPImagePicker

class EditProfileVC: UIViewController {
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var userNameTxtFld: UITextField!
    @IBOutlet weak var bioTxtFld: UITextField!
    @IBOutlet weak var phoneNumberTxtFld: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var countryPickerBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var publicBtn: UIButton!
    
    var gender : String = ""
    var countryCode: String = "+91"
    var selectedImg : UIImage?
    var isPrivate : String = ""
    var viewModel = EditProfileViewModel()
    
    var config = YPImagePickerConfiguration()
    var imgPicker = YPImagePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        config.library.maxNumberOfItems = 4
        config.screens = [.library, .photo, .video]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Edit Profile"
        let cancleBtn = UIBarButtonItem(title:"Cancle", style: .plain, target: self, action: #selector(cancleBtnPressed))
        cancleBtn.tintColor = .black
        navigationItem.leftBarButtonItem = cancleBtn
        
        let doneBtn = UIBarButtonItem(title:"Done", style: .plain, target: self, action: #selector(doneBtnPressed))
        doneBtn.tintColor = UIColor(named: "GlobalBlue")
        navigationItem.rightBarButtonItem = doneBtn
    }
    
    
    @objc func cancleBtnPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneBtnPressed() {
        MessageLoader.shared.showLoader(withText: "Please wait saving User data..")
        viewModel.saveDataToFirebase(name: nameTxtFld.text, username: userNameTxtFld.text, bio: bioTxtFld.text, countryCode: countryCode, phoneNumber: phoneNumberTxtFld.text, gender: gender, isPrivate: isPrivate){ value in
            if value{
                MessageLoader.shared.hideLoader()
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }else{
                MessageLoader.shared.hideLoader()
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func changeProfileBtnPressed(_ sender: UIButton) {
        presentImagePicker()
    }
    
    func presentImagePicker() {
        if let topViewController = UIApplication.topViewController() {
            if topViewController.presentedViewController is YPImagePicker {
                return
            }
        }
        config.library.maxNumberOfItems = 4
        config.screens = [.library, .photo]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
        imgPicker.didFinishPicking { [weak self] items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    MessageLoader.shared.showLoader(withText: "Profile Photo Uploading..")
                    self?.viewModel.saveUserImageToFirebase(image: photo.image) { result in
                        switch result {
                        case .success(let url):
                            print(url)
                            // Convert the URL to a string before saving
                            let urlString = url.absoluteString
                            Data.shared.saveData(urlString, key: "ProfileUrl") { _ in
                                if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid) {
                                    self?.viewModel.saveUserProfileImageToFirebaseDatabase(uid: uid, imageUrl: urlString) { result in
                                        switch result {
                                        case .success(let data):
                                            print(data)
                                            MessageLoader.shared.hideLoader()
                                        case .failure(let error):
                                            print(error)
                                            MessageLoader.shared.hideLoader()
                                        }
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error)
                            MessageLoader.shared.hideLoader()
                        }
                    }
                case .video(let video): break
                    
                }
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(imgPicker, animated: true, completion: nil)
    }

    
    
    @IBAction func genderSelectionBtnPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            gender = "Male"
            btn1.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            btn2.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        
        if sender.tag == 2 {
            gender = "Female"
            btn1.setImage(UIImage(systemName: "circle"), for: .normal)
            btn2.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        }
        
        print(gender)
    }
    
    
    @IBAction func isAccountPublicOrPrivateBtnPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            isPrivate = "false"
            publicBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            privateBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        
        if sender.tag == 2 {
            isPrivate = "true"
            publicBtn.setImage(UIImage(systemName: "circle"), for: .normal)
            privateBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        }
        
        print(isPrivate)
        
    }
    
    @IBAction func countryPickerBtnPressed(_ sender: UIButton) {
        countryPickerLabelTapped()
    }
}


extension EditProfileVC {
    
    func configuration(){
        updateUI()
    }
    
    
    func updateUI() {
        if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name){
            self.nameTxtFld.text = name
        }
        
        if let userName = FetchUserData.fetchUserInfoFromUserdefault(type: .userName){
            self.userNameTxtFld.text = userName
        }
        
        if let bio = FetchUserData.fetchUserInfoFromUserdefault(type: .bio){
            self.bioTxtFld.text = bio
        }
        
        if let gender = FetchUserData.fetchUserInfoFromUserdefault(type: .gender){
            self.gender  = gender
            if self.gender == "Male"{
                self.btn1.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                self.btn2.setImage(UIImage(systemName: "circle"), for: .normal)
            }
            if self.gender == "Female"{
                self.btn1.setImage(UIImage(systemName: "circle"), for: .normal)
                self.btn2.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            }
        }
        
        if let isPrivate = FetchUserData.fetchUserInfoFromUserdefault(type: .isPrivate){
            self.isPrivate = isPrivate
            if self.isPrivate == "false" {
                self.publicBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                self.privateBtn.setImage(UIImage(systemName: "circle"), for: .normal)
            }
            if self.isPrivate == "true"{
                self.publicBtn.setImage(UIImage(systemName: "circle"), for: .normal)
                self.privateBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            }
        }
        
        if let countryCode = FetchUserData.fetchUserInfoFromUserdefault(type: .countryCode){
            self.countryCode = "\(countryCode)"
            self.countryPickerBtn.setTitle(countryCode, for: .normal)
        }
        
        if let phoneNumber = FetchUserData.fetchUserInfoFromUserdefault(type: .phoneNumber){
            self.phoneNumberTxtFld.text  = phoneNumber
        }
        
        if let url = FetchUserData.fetchUserInfoFromUserdefault(type: .profileUrl) {
            if let imageURL = URL(string: url) {
                ImageLoader.loadImage(for: imageURL, into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            } else {
                print("Invalid URL: \(url)")
            }
        } else {
            print("URL is nil or empty")
        }
        
    }
}


extension EditProfileVC : ADCountryPickerDelegate , UIViewControllerTransitioningDelegate {
    
    @objc func countryPickerLabelTapped() {
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        picker.showCallingCodes = true
        picker.showFlags = true
        picker.pickerTitle = "Select a Country"
        picker.defaultCountryCode = "US"
        picker.forceDefaultCountryCode = false
        picker.closeButtonTintColor = UIColor.black
        picker.font = UIFont(name: "Helvetica Neue", size: 15)
        picker.flagHeight = 40
        picker.hidesNavigationBarWhenPresentingSearch = true
        picker.searchBarBackgroundColor = UIColor.lightGray
        picker.didSelectCountryClosure = { [weak self] name, code in
            guard let self = self else { return }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.modalPresentationStyle = .popover
        } else {
            picker.modalPresentationStyle = .custom
            picker.transitioningDelegate = self
        }
        present(picker, animated: true, completion: nil)
    }
    
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        countryPickerBtn.setTitle(dialCode, for: .normal)
        countryCode = dialCode
    }
}
