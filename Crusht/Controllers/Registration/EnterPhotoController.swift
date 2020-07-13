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
//import SDWebImage
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class EnterPhotoController: UIViewController {
    var imageFull = false
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
            let tutorialController = TutorialController()
            tutorialController.modalPresentationStyle = .fullScreen
            self.present(tutorialController, animated: true)
            
        }
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        view.backgroundColor = .white
    
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            leading: view.leadingAnchor,
                            bottom: nil,
                            trailing: view.trailingAnchor,
                            padding: .init(top: 12, left: 30, bottom: 0, right: 30))
        
        view.addSubview(selectPhotoButton)
        
        selectPhotoButton.anchor(top: view.topAnchor,
        leading: view.leadingAnchor,
        bottom: view.safeAreaLayoutGuide.bottomAnchor,
        trailing: view.trailingAnchor,
        padding: .init(top: view.bounds.height/4, left: 30, bottom: view.bounds.height/3, right: 30))
        
        view.addSubview(errorLabel)
        errorLabel.anchor(top: selectPhotoButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 18, left: 30, bottom: 0, right: 30))
        
    }
    
    let selectPhotoButton: UIButton = {
        let selectPhotoButton = UIButton(type: .system)
        selectPhotoButton.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        selectPhotoButton.setImage(#imageLiteral(resourceName: "CrushtLogoLiam-1").withRenderingMode(.alwaysOriginal), for: .normal)
        selectPhotoButton.setTitleColor(.black, for: .normal)
        selectPhotoButton.heightAnchor.constraint(equalToConstant: 500).isActive = true
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 500).isActive = true
        selectPhotoButton.imageView?.contentMode = .scaleAspectFill
       // selectPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
      //  selectPhotoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        selectPhotoButton.layer.cornerRadius = 70
        selectPhotoButton.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
        selectPhotoButton.layer.borderWidth = 4
        selectPhotoButton.clipsToBounds = true
        return selectPhotoButton
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        label.text = "Select Your Profile Picture"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Boop his nose to select a photo"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        return label
    }()
}

extension EnterPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        weak var selectedImage = info[.originalImage] as? UIImage
        let selectedImage2 = selectedImage?.resized(maxSize: CGSize(width: 500, height: 500))
        let imageButton = (picker as? CustomImagePickerController)?.imageBttn
        imageButton?.setImage(selectedImage2?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.imageFull = true

        picker.dismiss(animated: true)

        self.errorLabel.text = "Registering, hang tight..."

        self.selectPhotoButton.isEnabled = false

        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let imageData = selectedImage2?.jpegData(compressionQuality: 0.9) else { return }
        
        ref.putData(imageData, metadata: nil) { (nil, err) in
            guard err == nil else { return }
            ref.downloadURL { (url, err) in
                guard err == nil else { return }
                let imageUrl = url?.absoluteString ?? ""
                if imageUrl == "" {
                    print("fuck me man")
                }
                self.saveInfoToFirestore(imageUrl: imageUrl)
            }
        }
    }
}

extension UIImage {
      public func resized(maxSize: CGSize) -> UIImage? {
          let imageSize = self.size
          guard imageSize.height > 0, imageSize.width > 0 else { return nil }

          let ratio = min(maxSize.width/imageSize.width, maxSize.height/imageSize.height)
          let newSize = CGSize(width: imageSize.width*ratio, height: imageSize.height*ratio)

          let renderer = UIGraphicsImageRenderer(size: newSize)
          return renderer.image(actions: { (ctx) in
              self.draw(in: CGRect(origin: .zero, size: newSize))
          })
      }
  }
