//
//  PhotoController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import UserNotifications
import SDWebImage

extension EnterPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        registrationViewModel.checkFormValidity()
        registrationViewModel.bindableImage.value = image
        dismiss(animated: true, completion: nil)
    }
}

class EnterPhotoController: UIViewController {
   
    let registrationViewModel = RegistrationViewModel()
    
    var name = String()
    var birthday = String()
    var age = Int()
    var bio = String()
    var school = String()
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        
        //button.setBackgroundImage(#imageLiteral(resourceName: "top_left_profile"), for: .normal)
        //button.imageView?.contentMode = .scaleAspectFit
        //button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .white
        button.setBackgroundImage(#imageLiteral(resourceName: "CrushtLogoLiam"), for: .normal)
        
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 300).isActive = true
        button.widthAnchor.constraint(equalToConstant: 140).isActive = true
        button.imageView?.contentMode = .scaleAspectFill
        //button.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.layer.cornerRadius = 70
        button.clipsToBounds = true
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
         label.textColor = .white
        label.text = "Select Your Profile Picture"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        
        return label
    }()
    
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var selectPhotoButtonWidthAnchor = selectPhotoButton.widthAnchor.constraint(equalToConstant: 275)
    lazy var selectPhotoButtonHeightAnchor = selectPhotoButton.heightAnchor.constraint(equalToConstant: 275)
    
    @objc func handleSelectPhoto() {
        let alert = UIAlertController(title: "Access your photos", message: "Can Crusht open your photos so you can select a profile picture?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default){(UIAlertAction) in
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true)
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [selectPhotoButton, doneButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/9, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 4, left: 30, bottom: view.bounds.height/5, right: 30))
        
        stack.spacing = 15
        
    }
    
    
    let hud = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleDone(completion: @escaping (Error?) ->()) {
        if registrationViewModel.bindableImage.value == nil {
            hud.textLabel.text = "Please select a photo"
            hud.show(in: view)
            hud.dismiss(afterDelay: 2)
            return
        }
        else {
            handleRegister()
            
            
        }
        
    }
    
    fileprivate func showHUDWithError(error: Error) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    
    var phone: String!
    var gender = String()
    var sexYouLike = String()
    
        
    fileprivate func handleRegister() {
        
        registrationViewModel.age = age
        registrationViewModel.birthday = birthday
        registrationViewModel.fullName = name
        registrationViewModel.bio = bio
        registrationViewModel.school = school
        registrationViewModel.phone = phone
        registrationViewModel.gender = gender
        registrationViewModel.sexYouLike = sexYouLike
        
        hud.textLabel.text = "Registering..."
        hud.show(in: view)
        
        let profile = CustomTabBarController()
        registrationViewModel.performRegistration { [weak self] (err) in
            if let err = err {
                self?.showHUDWithError(error: err)
                return
            }
            
            self?.hud.dismiss()
            self?.present(profile, animated: true)
        }
        
    }
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        let bottomColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    

}
