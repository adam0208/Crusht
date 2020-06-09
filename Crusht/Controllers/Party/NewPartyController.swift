//
//  NewPartyController.swift
//  Crusht
//
//  Created by William Kelly on 2/17/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class NewPartyController: UIViewController {
    
    var imageFull = false
    var party: Party?
    var partyImageUrl = String()
    var phoneNumber = String()
        // MARK: - Life Cycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc private func handleSelectPhoto() {
            let imagePicker = CustomImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageBttn = self.selectPhotoButton
           self.present(imagePicker, animated: true)
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNotificationObservers()
            setupTapGesture()
            initializeUI()
        }
        
        // MARK: - Logic
        
        fileprivate func setupTapGesture() {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        }
        
        @objc fileprivate func handleTapDismiss() {
            self.view.endEditing(true)
        }
        
        fileprivate func setupNotificationObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        @objc fileprivate func handleKeyboardHide() {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = .identity
            })
        }
        //edit keyboard stuff later
        @objc fileprivate func handleKeyboardShow(notification: Notification) {
            // How to figure out how tall the keyboard actually is
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = value.cgRectValue
            
            // Let's try to figure out how tall the gap is from the register button to the bottom of the screen
            let bottomSpace = view.frame.height - stackView.frame.origin.y - (stackView.frame.height + 30)
            
            let difference = keyboardFrame.height - bottomSpace
            self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
        }
        
        // MARK: - User Interface

    
    let selectPhotoButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        button.setTitle("Select Party Photo", for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
         
            button.clipsToBounds = true
            return button
        }()
        
        
        let headingLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.textColor = .white
            label.text = "Enter a party description:"
            label.numberOfLines = 0
            return label
        }()
        
        
        let textView: UITextView = {
            let tv = ReportTextView()
            tv.font = UIFont.systemFont(ofSize: 18)
             tv.textColor = .black
            tv.layer.cornerRadius = 18
            tv.clipsToBounds = true
            tv.adjustsFontForContentSizeCategory = true
            return tv
        }()
        
        let inviteButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Invite People", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
            button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
            button.setTitleColor(.white, for: .normal)
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(createParty), for: .touchUpInside)
            return button
        }()
    
    let startTime: UITextField = {
        let tf = UITextField()
           tf.placeholder = "Start Time"
           tf.backgroundColor = .white
           tf.layer.cornerRadius = 15
           tf.widthAnchor.constraint(equalToConstant: 160).isActive = true
           tf.font = UIFont.systemFont(ofSize: 25)
           tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
            tf.textAlignment = .center

           return tf
    }()
    
    let endTime: UITextField = {
        let tf = UITextField()
           tf.placeholder = "End Time"
           tf.backgroundColor = .white
           tf.layer.cornerRadius = 15
           tf.font = UIFont.systemFont(ofSize: 25)
           tf.widthAnchor.constraint(equalToConstant: 160).isActive = true
           tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
            tf.textAlignment = .center
           return tf
    }()
    
    let partyTitle: UITextField = {
        let tf = NameTextField()
           tf.placeholder = "Enter Party Title"
           tf.backgroundColor = .white
           tf.layer.cornerRadius = 15
           tf.font = UIFont.systemFont(ofSize: 25)
       
           tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
           return tf
    }()
    
    let location: UITextField = {
        let tf = NameTextField()
           tf.placeholder = "Enter Location"
           tf.backgroundColor = .white
           tf.layer.cornerRadius = 15
           tf.font = UIFont.systemFont(ofSize: 25)
            tf.widthAnchor.constraint(equalToConstant: 500).isActive = true
           tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
           return tf
    }()
    
    lazy var stackView = UIStackView(arrangedSubviews: [startTime, endTime])
    
    let scrollView = UIScrollView()

    private func initializeUI() {
        navigationItem.title = "New Party"
        view.addGradientSublayer()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-back-filled-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))
        view.addSubview(scrollView)
        
        scrollView.addSubview(selectPhotoButton)
        scrollView.fillSuperview()
        selectPhotoButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 0, bottom: 0, right: 0))
        
        scrollView.addSubview(partyTitle)
        partyTitle.widthAnchor.constraint(equalToConstant: CGFloat(Int(view.bounds.width/1.3))).isActive = true
        partyTitle.anchor(top: selectPhotoButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: view.bounds.width / 16, bottom: 0, right: view.bounds.width / 8))
        
        scrollView.addSubview(location)
        location.widthAnchor.constraint(equalToConstant: CGFloat(Int(view.bounds.width/1.3))).isActive = true
        location.anchor(top: partyTitle.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: view.bounds.width / 16, bottom: 0, right: view.bounds.width / 8))
        
        scrollView.addSubview(headingLabel)
        headingLabel.anchor(top: location.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: view.bounds.width / 16, bottom: 0, right: 0))
        
        scrollView.addSubview(textView)
        textView.anchor(top: headingLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: view.bounds.width / 16, bottom: 0, right: view.bounds.width / 16))
        
        scrollView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 14
        stackView.distribution = .fillEqually
        stackView.anchor(top: textView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: view.bounds.width / 8, bottom: 0, right: view.bounds.width / 8))
        
        scrollView.addSubview(inviteButton)
        inviteButton.anchor(top: stackView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 20, left: view.bounds.width / 8, bottom: 20, right: view.bounds.width / 8))
//        view.addSubview(stackView)
//        stackView.axis = .vertical
//        stackView.spacing = 25
//        stackView.anchor(top: view.topAnchor,
//                         leading: view.leadingAnchor,
//                         bottom: view.bottomAnchor,
//                         trailing: view.trailingAnchor,
//                         padding: .init(top: view.bounds.height / 12, left: view.bounds.width / 9, bottom: view.bounds.height / 12, right: view.bounds.width / 9))
        
        }
    
    fileprivate func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    //fix to send to party controller
    @objc fileprivate func handleBack() {
         let customtabController = CustomTabBarController()
        customtabController.modalPresentationStyle = .fullScreen
        self.present(customtabController, animated: true)
    }
    
    @objc fileprivate func createParty() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let partyUID = randomString(length: 20)
        
        let docData: [String: Any] = ["partyName": self.partyTitle.text ?? "",
                                      "partyLocation": self.location.text ?? "",
                                      "partyPhotoUrl": partyImageUrl,
                                      "partyDetails": textView.text ?? "No description",
                                      "hostUID": uid,
                                      "partyUID": partyUID,
                                      "guests": [phoneNumber]]
                                      
        Firestore.firestore().collection("parties").document(partyUID).setData(docData)
        
   //     let inviteController = InviteController()
        let inviteTabController = InviteTabController()
                     let myBackButton = UIBarButtonItem()
                     myBackButton.title = " "
                     self.navigationItem.backBarButtonItem = myBackButton
        inviteTabController.contactsController.partyTitle = self.partyTitle.text ?? ""
        inviteTabController.contactsController.location = self.location.text ?? ""
        inviteTabController.contactsController.partyUID = partyUID
        
        self.tabBarController?.navigationController?.pushViewController(inviteTabController, animated: true)

    }

}

extension NewPartyController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        weak var selectedImage = info[.originalImage] as? UIImage
        let selectedImage2 = selectedImage?.resizeImage(targetSize: CGSize(width: 200, height: 200))
        let imageButton = (picker as? CustomImagePickerController)?.imageBttn
        imageButton?.setImage(selectedImage2?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.imageFull = true

        dismiss(animated: true)

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
                self.partyImageUrl = imageUrl
            }
        }
    }
}
