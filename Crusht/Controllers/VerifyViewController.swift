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

class VerifyNumberText: UITextField {
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


class VerifyViewController: UIViewController {
    
    var phoneNumber: String!
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Enter Code"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        label.textColor = .black
        return label
    }()
    
    let verificationCodeText: UITextField = {
        let tf = VerifyNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "XXXXXX"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 22
        tf.font = UIFont.systemFont(ofSize: 35)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleVerify), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [verificationCodeText, verifyButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
          label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
         stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 4, left: view.bounds.height/9, bottom: view.bounds.height/2.2, right: view.bounds.height/9))
        
        
        stack.spacing = 20
        
    }
    
    
    
    @objc fileprivate func handleVerify() {
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVerificationID")!, verificationCode: verificationCodeText.text!)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil {
                print("error: \(String(describing: error?.localizedDescription))")
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {return}
                print("signed in")
                let docData: [String: Any] =
                    ["Full Name": "",
                     "uid": uid,
                    "PhoneNumber": self.phoneNumber ?? "",
                    "Age": "",
        
                        "ImageUrl1": "",
                        "ImageUrl2": "",
                        "ImageUrl3": "",
                       
                        "Birthday": "",
                        "School": "",
                        "Bio": "",
                        "minSeekingAge": 18,
                        "maxSeekingAge": 40,
                        "maxDistance": 5,
                        "email": "",
                        "fbid": "",
                        "deviceID": Messaging.messaging().fcmToken ?? "",
                        "Gender-Preference": "",
                        "User-Gender": ""
                     ]
                
                Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: self.phoneNumber ?? "").getDocuments(completion: { (snapshot, err) in
                    if let err = err {
                        print(err)
                    }
                    if (snapshot?.isEmpty)! {
                        Firestore.firestore().collection("users").document(uid).setData(docData)
                        let enterName = EnterNameController()
                        enterName.phone = self.phoneNumber ?? ""
                        self.present(enterName, animated: true)
                    }
                    else {
                        let profileController = ProfilePageViewController()
                        self.present(profileController, animated: true)
                    }
                })
                
            }
        }
        
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
}



