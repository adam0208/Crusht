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
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            guard error == nil, let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["Full Name": "",
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
                    enterName.phone = self.phoneNumber ?? ""
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
        view.addGradientSublayer()
        
        let stack = UIStackView(arrangedSubviews: [verificationCodeText, verifyButton])
        view.addSubview(stack)
        stack.axis = .vertical
        view.addSubview(goBackBttn)
        goBackBttn.anchor(top: view.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: nil,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        view.addSubview(label)
        label.anchor(top: goBackBttn.bottomAnchor,
                     leading: view.leadingAnchor,
                     bottom: nil,
                     trailing: view.trailingAnchor,
                     padding: .init(top: view.bounds.height / 8, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor,
                     leading: view.leadingAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     trailing: view.trailingAnchor,
                     padding: .init(top: 4, left: view.bounds.height / 9, bottom: view.bounds.height / 2.2, right: view.bounds.height / 9))
        
        stack.spacing = 20
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter Code"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    private let verificationCodeText: UITextField = {
        let tf = VerifyNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "XXXXXX"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 22
        tf.font = UIFont.systemFont(ofSize: 35)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return tf
    }()
    
    private let goBackBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Didn't Get a Code?", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.layer.cornerRadius = 22
        
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
