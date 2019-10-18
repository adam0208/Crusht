////
////  CheckVerificationViewController.swift
////  Crusht
////
////  Created by William Kelly on 1/31/19.
////  Copyright © 2019 William Kelly. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class CheckVerificationViewController: UIViewController {
//    
//    let errorLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//       // label.text = "We need your phone number to match you with your contacts"
//        return label
//    }()
//    
//    let codeField: UITextField = {
//        let tf = VerifyNumberText()
//        tf.keyboardType = UIKeyboardType.phonePad
//        tf.placeholder = "XXXXXX"
//        tf.backgroundColor = .white
//        tf.layer.cornerRadius = 22
//        tf.font = UIFont.systemFont(ofSize: 35)
//        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        
//        
//        return tf
//    }()
//    
//    let verifyButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Verify", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        
//        button.layer.cornerRadius = 22
//        
//        button.addTarget(self, action: #selector(validateCode), for: .touchUpInside)
//        return button
//    }()
//    
//    
//    override func viewDidLoad() {
//        self.errorLabel.text = nil
//        super.viewDidLoad()
//        
//        setupGradientLayer()
//        
//        let stack = UIStackView(arrangedSubviews: [codeField, verifyButton, errorLabel])
//        view.addSubview(stack)
//        
//        stack.axis = .vertical
//        
//        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 250, left: 30, bottom: 250, right: 30))
//        
//        
//        stack.spacing = 20
//        
//    }
//    
//   // @IBOutlet var codeField: UITextField! = UITextField()
////    @IBOutlet var errorLabel: UILabel! = UILabel()
//    
//    var countryCode: String?
//    var phoneNumber: String?
//    var resultMessage: String?
//    var fbid: String?
//    
//    @objc func validateCode() {
//        if let code = codeField.text {
//            VerifyAPI.validateVerificationCode(self.countryCode!, self.phoneNumber!, code) { checked in
//                if (checked.success) {
//                    self.resultMessage = checked.message
//                    
//                    self.fetchCurrentUser()
//                        
//                } else {
//                    self.errorLabel.text = checked.message
//                }
//            }
//        }
//    }
//    
//    var user: User?
//    
//    fileprivate func fetchCurrentUser() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            //print(snapshot?.data())
//            guard let dictionary = snapshot?.data() else {return}
//            self.user = User(dictionary: dictionary)
//            
//            self.registerUserIntoFirebase()
//            
//        }
//    }
//            
//    
//    fileprivate func registerUserIntoFirebase() {
//        
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        print("signed in")
//        let docData: [String: Any] =
//            ["Full Name": user?.name ?? "",
//             "uid": uid,
//             "PhoneNumber": "\(self.countryCode ?? "")\(self.phoneNumber ?? "")",
//             "School": user?.school ?? "",
//             "Age": user?.age ?? "",
//             "Bio": user?.bio ?? "",
//             "minSeekingAge": 18,
//             "maxSeekingAge": 50,
//             "fbid": "",
//             "ImageUrl1": user?.imageUrl1 ?? ""
//        ]
//        
//        Firestore.firestore().collection("users").document(uid).setData(docData)
//        
//        let enterPhoneInfo = EnterMorePhoneInfoViewController()
//        
//        self.present(enterPhoneInfo, animated: true)
//        
//    }
//
//    
//    
//    let gradientLayer = CAGradientLayer()
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        gradientLayer.frame = view.bounds
//    }
//    
//    
//    fileprivate func setupGradientLayer() {
//        
//        let topColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
//        let bottomColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
//        // make sure to user cgColor
//        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        gradientLayer.locations = [0, 1]
//        view.layer.addSublayer(gradientLayer)
//        gradientLayer.frame = view.bounds
//}
//
//    
//}
