//
//  EditPhotoController.swift
//  Crusht
//
//  Created by William Kelly on 6/29/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class EditPhotoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var user: User?
        var madeChange = false
        var delegate: SettingsControllerDelegate?
    
        lazy var image1Button = createBttn(selector: #selector(handleSelectPhoto))
        lazy var image2Button = createBttn(selector: #selector(handleSelectPhoto))
        lazy var image3Button = createBttn(selector: #selector(handleSelectPhoto))
        
        //UI
        
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Your Photos"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let errorLabel: UILabel = {
            let label = UILabel()
            label.text = "Please enter your name"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
            return button
        }()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
        }
     

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            loadUserPhotos()
     
            view.addSubview(label)
            label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 12, left: 30, bottom: 0, right: 30))
            
            view.addSubview(backButton)
            backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
            
                let stack = UIStackView(arrangedSubviews: [image1Button, image2Button, image3Button])
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.spacing = 7
            
            view.addSubview(stack)
            
            stack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/7, left: 80, bottom: 50, right: 80))
            
        }
        
        //Functions

        @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selectedImage = info[.originalImage] as? UIImage
            let selectedImage2 = selectedImage?.resized(maxSize: CGSize(width: 500, height: 500))
    
            let imageButton = (picker as? CustomImagePickerController)?.imageBttn
            imageButton?.setImage(selectedImage2?.withRenderingMode(.alwaysOriginal), for: .normal)
            picker.dismiss(animated: true)
    
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
            guard let uploadData = selectedImage2?.jpegData(compressionQuality: 0.9) else {return}
            ref.putData(uploadData, metadata: nil) { (nil, err) in
                if err != nil {
                    return
                }
                ref.downloadURL(completion: { (url, err) in
                    if err != nil {
                        return
                    }
    
                    if imageButton == self.image1Button {
                        self.user?.imageUrl1 = url?.absoluteString
                    } else if imageButton == self.image2Button {
                        self.user?.imageUrl2 = url?.absoluteString
                    }
                    else {
                        self.user?.imageUrl3 = url?.absoluteString
                    }
                    self.saveInfoToFirestore(imageUrl1: self.user?.imageUrl1 ?? "", imageUrl2: self.user?.imageUrl2 ?? "", imageUrl3: self.user?.imageUrl3 ?? "")
                    
                })
            }
        }
    
        fileprivate func loadUserPhotos() {
            // Maybe refactor this
            if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {

              //  Nuke.loadImage(with: url, into: self.image1Button)
                SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                    self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
            if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {

           //     Nuke.loadImage(with: url, into: self.image2Button)
                SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                    self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
            if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
               // Nuke.loadImage(with: url, into: self.image3Button)

                SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                    self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
        }

        @objc func handleSelectPhoto(button: UIButton) {
            let imagePicker = CustomImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageBttn = button
            present(imagePicker, animated: true)
        }
        
        @objc fileprivate func handleBack() {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.popViewController(animated: true) {
                           if self.madeChange == true {
                       self.delegate?.didSaveSettings()
                       }
            }
        }
    
        func createBttn(selector: Selector) -> UIButton {
            let button = UIButton(type: .system)
            //button.setTitle("Select Photo", for: .normal)
            button.backgroundColor = .white
            button.setImage(#imageLiteral(resourceName: "icons8-photo-gallery-100").withRenderingMode(.alwaysOriginal), for: .normal)
            button.layer.cornerRadius = 95
            button.clipsToBounds = true
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFill
            button.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0.6705882353, alpha: 1)
            button.layer.borderWidth = 4
            return button
        }
    
    private func saveInfoToFirestore(imageUrl1: String, imageUrl2: String, imageUrl3: String) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] = ["ImageUrl1": imageUrl1,
                                      "ImageUrl2": imageUrl2,
                                      "ImageUrl3": imageUrl3]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (err) in
            guard err == nil else { return }
            self.madeChange = true
            self.loadUserPhotos()
        
        }
    }
}

