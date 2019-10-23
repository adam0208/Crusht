//
//  EnterPhotoController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import SDWebImage

class EnterPhotoController: UIViewController {
    var imageFull = false
    var selectPhotoButton: UIButton!

    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func handleSelectPhoto() {
        let alert = UIAlertController(title: "Access your photos", message: "Can Crusht open your photos so you can select a profile picture?", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Yes", style: .default){(UIAlertAction) in
            let imagePicker = CustomImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageBttn = self.selectPhotoButton
           self.present(imagePicker, animated: true)
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    private func saveInfoToFirestore(imageUrl: String){
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] = ["ImageUrl1": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (err) in
            guard err == nil else { return }
            let customtabController = CustomTabBarController()
            self.present(customtabController, animated: true)
        }
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        view.addGradientSublayer()
        setupButton()
        
        let stack = UIStackView(arrangedSubviews: [selectPhotoButton, errorLabel])
        view.addSubview(stack)
        stack.axis = .vertical
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     leading: view.leadingAnchor,
                     bottom: nil,
                     trailing: view.trailingAnchor,
                     padding: .init(top: view.bounds.height/9, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor,
                     leading: view.leadingAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     trailing: view.trailingAnchor,
                     padding: .init(top: 4, left: 30, bottom: view.bounds.height/4, right: 30))
        
        stack.spacing = 15
        errorLabel.isHidden = true
    }
    
    private func setupButton() {
        selectPhotoButton = UIButton(type: .system)
        selectPhotoButton.backgroundColor = .white
        selectPhotoButton.setBackgroundImage(#imageLiteral(resourceName: "CrushtLogoLiam"), for: .normal)
        selectPhotoButton.setTitleColor(.black, for: .normal)
        selectPhotoButton.heightAnchor.constraint(equalToConstant: 300).isActive = true
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        selectPhotoButton.imageView?.contentMode = .scaleAspectFill
        selectPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        selectPhotoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        selectPhotoButton.layer.cornerRadius = 70
        selectPhotoButton.clipsToBounds = true
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Select Your Profile Picture"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select a photo"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
}

extension EnterPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageBttn
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.imageFull = true

        dismiss(animated: true)

        self.errorLabel.text = "Registering, hang tight..."
        self.errorLabel.isHidden = false
        self.selectPhotoButton.isEnabled = false

        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        ref.putData(imageData, metadata: nil) { (nil, err) in
            guard err == nil else { return }
            ref.downloadURL { (url, err) in
                guard err == nil else { return }
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl)
            }
        }
    }
}