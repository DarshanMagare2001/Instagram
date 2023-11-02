//
//  EditProfileVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit
import FirebaseAuth
import Kingfisher
import ADCountryPicker

class EditProfileVC: UIViewController {
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var userNameTxtFld: UITextField!
    @IBOutlet weak var bioTxtFld: UITextField!
    @IBOutlet weak var phoneNumberTxtFld: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var countryPickerBtn: UIButton!
    private lazy var imagePicker: ImagePicker = {
        let imagePicker = ImagePicker()
        imagePicker.delegate = self
        return imagePicker
    }()
    var gender : String = ""
    var countryCode: String = "+91"
    var selectedImg : UIImage?
    var viewModel = EditProfileViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        
    }
    
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        LoaderVCViewModel.shared.showLoader()
        viewModel.saveDataToFirebase(name: nameTxtFld.text, username: userNameTxtFld.text, bio: bioTxtFld.text, countryCode: countryCode, phoneNumber: phoneNumberTxtFld.text, gender: gender){ value in
            if value{
                LoaderVCViewModel.shared.hideLoader()
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }else{
                LoaderVCViewModel.shared.hideLoader()
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func changeProfileBtnPressed(_ sender: UIButton) {
        imagePicker.present(parent: self, sourceType: .photoLibrary)
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
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func countryPickerBtnPressed(_ sender: UIButton) {
        countryPickerLabelTapped()
    }
}


extension EditProfileVC {
    
    func configuration(){
        //        activityStop()
        updateUI()
        initViewModel()
        observeEvent()
        
    }
    
    func initViewModel(){
    }
    
    
    func observeEvent() {
    }
    
    
    func updateUI() {
        Data.shared.getData(key: "Name") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.nameTxtFld.text = data
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "UserName") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.userNameTxtFld.text = data
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "Bio") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.bioTxtFld.text = data
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "Gender") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.gender  = data
                if self.gender == "Male"{
                    self.btn1.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                    self.btn2.setImage(UIImage(systemName: "circle"), for: .normal)
                }
                if self.gender == "Female"{
                    self.btn1.setImage(UIImage(systemName: "circle"), for: .normal)
                    self.btn2.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                }
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "CountryCode") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.countryCode = "\(data)"
                self.countryPickerBtn.setTitle(data, for: .normal)
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "PhoneNumber") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.phoneNumberTxtFld.text  = data
            case .failure(let error):
                print(error)
            }
        }
        
        Data.shared.getData(key: "ProfileUrl") { (result: Result<String?, Error>) in
            switch result {
            case .success(let urlString):
                if let url = urlString {
                    if let imageURL = URL(string: url) {
                        ImageLoader.loadImage(for: imageURL, into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                    } else {
                        print("Invalid URL: \(url)")
                    }
                } else {
                    print("URL is nil or empty")
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
        
    }
}

extension EditProfileVC: ImagePickerDelegate , UIViewControllerTransitioningDelegate {
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        userImg.image = image
        selectedImg = image
        imagePicker.dismiss()
        LoaderVCViewModel.shared.showLoader()
        viewModel.saveUserImageToFirebase(image: image) { result in
            switch result {
            case .success(let url):
                print(url)
                // Convert the URL to a string before saving
                let urlString = url.absoluteString
                Data.shared.saveData(urlString, key: "ProfileUrl") { _ in
                    Data.shared.getData(key: "CurrentUserId") { (result:Result<String?,Error>) in
                        switch result {
                        case .success(let uid):
                            if let uid = uid {
                                self.viewModel.saveUserProfileImageToFirebaseDatabase(uid: uid, imageUrl: urlString) { result in
                                    switch result {
                                    case .success(let data):
                                        print(data)
                                        LoaderVCViewModel.shared.hideLoader()
                                    case .failure(let error):
                                        print(error)
                                        LoaderVCViewModel.shared.hideLoader()
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                LoaderVCViewModel.shared.hideLoader()
            }
        }
    }
    
    
    func cancelButtonDidClick(on imageView: ImagePicker) { imagePicker.dismiss() }
    func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool,
                     to sourceType: UIImagePickerController.SourceType) {
        guard grantedAccess else { return }
        imagePicker.present(parent: self, sourceType: sourceType)
    }
}

extension EditProfileVC : ADCountryPickerDelegate {
    
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
