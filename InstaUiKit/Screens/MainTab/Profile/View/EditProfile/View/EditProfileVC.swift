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
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var activityPicker: UIActivityIndicatorView!
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
        // After successful user sign-in, get the user's UID
        if let uid = Auth.auth().currentUser?.uid {
            activityStart()
            ProfileViewModel.shared.saveUserToFirebase(uid: uid, name: nameTxtFld.text, username: userNameTxtFld.text, bio: bioTxtFld.text, phoneNumber: "\(countryCode ?? "")\(phoneNumberTxtFld.text ?? "")", gender: gender, image: selectedImg, countryCode: countryCode){ result in
                switch result {
                case .success:
                    print("User data saved successfully in database.")
                    self.viewModel.saveProfileToUserDefaults(uid: uid, name: self.nameTxtFld.text ?? "", username: self.userNameTxtFld.text ?? "", bio: self.bioTxtFld.text ?? "", phoneNumber:self.phoneNumberTxtFld.text ?? "" , gender: self.gender ?? "", countryCode: self.countryCode ?? ""){ result in
                        switch result {
                        case.success:
                            print("Profile successfully saved in userdefault.")
                            DispatchQueue.main.async {
                                self.activityStop()
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                   
                case .failure(let error):
                    print("Error saving user data: \(error)")
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
        activityStart()
        updateUI()
        initViewModel()
        observeEvent()
        
    }
    
    func initViewModel(){
        viewModel.fetchProfile()
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .loading:
                print("loading")
                
            case .stopLoading:
                print("stopLoading")
                
            case .loaded:
                print("loaded")
                self.activityStop()
                print(self.viewModel.userModel?.imageURL)
                DispatchQueue.main.async {
                    self.updateUI()
                }
            case .error(let error):
                print(error)
                self.activityStop()
            }
        }
    }
    
    
    func updateUI() {
        if let imageURLString = self.viewModel.userModel?.imageURL, let imageURL = URL(string: imageURLString) {
            // Use Kingfisher to set the image directly from the URL
            self.userImg.kf.setImage(with: imageURL)
        }
        viewModel.fetchProfileFromUserDefaults { result in
            switch result {
            case.success(let profileData):
                if let name = profileData.name {
                    if name != "" {
                        self.nameTxtFld.placeholder = "\(name)"
                        print(name)
                    }
                }
                
                if let username = profileData.username {
                    if username != "" {
                        self.userNameTxtFld.placeholder = "\(username)"
                        print(username)
                    }
                }
                
                if let bio = profileData.bio {
                    if bio != "" {
                        self.bioTxtFld.placeholder = "\(bio)"
                        print(bio)
                    }
                }
                
                if let phoneNumber = profileData.phoneNumber {
                    if phoneNumber != ""{
                        self.phoneNumberTxtFld.placeholder = "\(phoneNumber)"
                        print(phoneNumber)
                    }
                }
                
                if let gender = profileData.gender {
                    if  gender == "Male" {
                        self.btn1.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                        self.btn2.setImage(UIImage(systemName: "circle"), for: .normal)
                    }else if  gender == "Female" {
                        self.btn1.setImage(UIImage(systemName: "circle"), for: .normal)
                        self.btn2.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                    }
                }
                
                
                if let countryCode = profileData.countryCode {
                    if countryCode != ""{
                        self.countryCode = countryCode
                        print(countryCode)
                        self.countryPickerBtn.setTitle(countryCode, for: .normal)
                    }
                }
                
            case.failure(let Error):
                print(Error.localizedDescription)
            }
        }
    }
    
    func activityStart(){
        pickerView.isHidden = false
        activityPicker.startAnimating()
    }
    
    func activityStop(){
        pickerView.isHidden = true
        activityPicker.stopAnimating()
    }
    
}

extension EditProfileVC: ImagePickerDelegate , UIViewControllerTransitioningDelegate {
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        userImg.image = image
        selectedImg = image
        imagePicker.dismiss()
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
