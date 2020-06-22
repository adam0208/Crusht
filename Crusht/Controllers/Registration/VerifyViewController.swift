//
//  VerifyViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/6/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class VerifyViewController: UIViewController {
    var phoneNumber: String!

    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func goBack() {
        let phoneControlla = PhoneNumberViewController()
        self.present(phoneControlla, animated: true)
    }
    
    @objc private func handleVerify() {
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVerificationID")!, verificationCode: verificationCodeText.text!)
        Auth.auth().signIn(with: credential) { (user, error) in
            guard error == nil, let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["Full Name": "",
                                          "First Name": "",
                                          "Last Name": "",
                                          "maxVenueDistance": 4,
                                          "CurrentVenue": "",
                                          "uid": uid,
                                          "PhoneNumber": self.phoneNumber ?? "",
                                          "Age": "",
                                          "ImageUrl1": "",
                                          "Birthday": "",
                                          "School": "",
                                          "Bio": "",
                                          "minSeekingAge": 18,
                                          "maxSeekingAge": 40,
                                          "maxDistance": 5,
                                          "deviceID": Messaging.messaging().fcmToken ?? "",
                                          "Gender-Preference": "",
                                          "User-Gender": ""
                                        ]
            
            Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: self.phoneNumber ?? "").getDocuments { (snapshot, err) in
                if (snapshot?.isEmpty)! {
                    Firestore.firestore().collection("users").document(uid).setData(docData)
                    let enterName = EnterNameController()
                    enterName.modalPresentationStyle = .fullScreen
                    //enterName.phone = self.phoneNumber ?? ""
                    self.present(enterName, animated: true)
                }
                else {
                    let profileController = CustomTabBarController()
                    profileController.modalPresentationStyle = .fullScreen
                    self.present(profileController, animated: true)
                }
            }
        }
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        view.backgroundColor = .white
     
        view.addSubview(goBackBttn)
        goBackBttn.anchor(top: view.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: nil,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        view.addSubview(verificationCodeText)
        verificationCodeText.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 70, bottom: 0, right: 70))
        
        view.addSubview(underline)
        underline.anchor(top: verificationCodeText.bottomAnchor, leading: verificationCodeText.leadingAnchor, bottom: nil, trailing: verificationCodeText.trailingAnchor)
     
        view.addSubview(verifyButton)
        verifyButton.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 120, bottom: 0, right: 120))
        
    }
    
    private let underline: UIView = {
         let view = UIView()
         view.heightAnchor.constraint(equalToConstant: 4).isActive = true
         view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6705882353, alpha: 1)
         return view
     }()
    
    private let verificationCodeText: UITextField = {
        let tf = VerifyNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "Enter Code"
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 35)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        tf.textAlignment = .center
        return tf
    }()
    
    private let goBackBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Didn't Get a Code?", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 90).isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        return button
    }()
    
    private let verifyButton: UIButton = {
             let button = UIButton(type: .system)
             button.setTitle("Verify", for: .normal)
             button.setTitleColor(.white, for: .normal)
             button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
             button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
             button.titleLabel?.adjustsFontForContentSizeCategory = true
             button.layer.cornerRadius = 18
             
        
        button.addTarget(self, action: #selector(handleVerify), for: .touchUpInside)
        return button
    }()
}

// MARK: - VerifyNumberText

private class VerifyNumberText: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 100)
    }
}
