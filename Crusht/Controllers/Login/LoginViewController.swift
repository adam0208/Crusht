//
//  LoginViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/6/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
//import Nuke
import SDWebImage

import WebKit

protocol LoginControllerDelegate {
    func didFinishLoggingIn()
}

class LoginViewController: UIViewController, UINavigationControllerDelegate {
    let tap = UITapGestureRecognizer()
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var delegate: LoginControllerDelegate?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func handleLogin () {
        let phoneNumberViewController = PhoneNumberViewController()
        phoneNumberViewController.modalPresentationStyle = .fullScreen
        present(phoneNumberViewController, animated: true)
    }
    
    @objc private func handlePrivacy() {
        if let url = URL(string: "https://app.termly.io/document/privacy-policy/7b4441c3-63d0-4987-a99d-856e5053ea0c"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc private func handleTerms() {
        let termsController = TermsViewController()
        self.navigationController?.pushViewController(termsController, animated: true)
    }
    
    // MARK: - User Interface
    
    private func initializeUI () {
        view.addGradientSublayer()
        navigationController?.isNavigationBarHidden = true

        let logoImage = UIImageView()
        logoImage.image = #imageLiteral(resourceName: "CrushtLogoLiam")
        logoImage.contentMode = .scaleAspectFit
        tap.addTarget(self, action: #selector(handleLogin))
        logoImage.addGestureRecognizer(tap)
        logoImage.isUserInteractionEnabled = true
        view.addSubview(logoImage)
        
        logoImage.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: nil,
                         trailing: view.trailingAnchor,
                         padding: .init(top: 60, left: 0, bottom: 0, right: 0))
        
        view.addSubview(text)
        text.anchor(top: logoImage.bottomAnchor,
                    leading: view.leadingAnchor,
                    bottom: nil,
                    trailing: view.trailingAnchor,
                    padding: .init(top: 14, left: 40, bottom: 0, right: 40))
       
        view.addSubview(privacyButton)
        privacyButton.addTarget(self, action: #selector(handleTerms), for: .touchUpInside)
        privacyButton.anchor(top: nil,
                             leading: view.leadingAnchor,
                             bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 0, left: 10, bottom: 20, right: 10))
        
        view.bringSubviewToFront(text)
    }
    
    private let text: UILabel = {
        let label = UILabel()
        label.text = "Boop His Nose to Log In!"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("By Logging In You Agree to our Terms of Use", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        button.backgroundColor = .clear
        button.titleLabel?.numberOfLines = 0
        button.heightAnchor.constraint(equalToConstant: 90).isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
        return button
    }()
   
}

//    let LoginBttn: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Log in with Email", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//
//        button.layer.cornerRadius = 22
//
//        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
//        return button
//    }()
//
//
//
//    let FBLoginBttn: UIButton = {
//
//        let button = UIButton(type: .system)
//        button.setTitle("Log in with Facebook", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.layer.cornerRadius = 22
//        button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
//        return button
//    }()
//
//
//
//    let phoneLoginBttn: UIButton = {
//
//        let button = UIButton(type: .system)
//        button.setTitle("Log in with Phone", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.layer.cornerRadius = 22
//        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
//        return button
//    }()

//    let registrationViewModel = RegistrationViewModel()
//    let registeringHUD = JGProgressHUD(style: .dark)
//
//    @objc fileprivate func handleRegister() {
//        print("Register our User in Firebase Auth")
//        let profilePageViewController = ProfilePageViewController()
//        registrationViewModel.performRegistration { [weak self] (err) in
//            if let err = err {
//                self?.showHUDWithError(error: err)
//                return
//            }
//            self?.present(profilePageViewController, animated: true)
//        }
//    }
    
//    @objc func loginButtonClicked() {
//        let loginManager = LoginManager()
//        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self)  { (loginResult) in
//            switch loginResult {
//            case .failed(let error):
//                print("cccccccccccccccccccccccccccccccccccccc",error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
//                print("Logged in!")
//                self.performRegistration()
//            }
//
//        }
//    }
//
//
//    fileprivate func performRegistration() {
//
//        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//        Auth.auth().signInAndRetrieveData(with: credential) { (user, err) in
//            if let err = err {
//                print("There was an error bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", err)
//
//                return
//            }
//
//            print("Succesfully authenticated with Firebase.")
//            self.fetchFacebookUser()
//        }
//    }
    

    
//    fileprivate func fetchFacebookUser() {
//        let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
//        req.start({ (connection, result) in
//            switch result {
//            case .failed(let error):
//                print(error)
//            case .success(let graphResponse):
//                if let responseDictionary = graphResponse.dictionaryValue {
//                    print(responseDictionary)
//                    let firstNameFB = responseDictionary["first_name"] as? String
//                    let lastNameFB = responseDictionary["last_name"] as? String
//                    let socialIdFB = responseDictionary["id"] as? String
//                    let genderFB = responseDictionary["gender"] as? String
//                    let emailFB = responseDictionary["email"] as? String
//                    let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
//                    let photoData = pictureUrlFB!["data"] as? [String:Any]
//                    let photoUrl = photoData!["url"] as? String
//
//                    print(firstNameFB ?? "", lastNameFB ?? "", socialIdFB ?? "", genderFB ?? "", photoUrl ?? "")
//
//                    self.fullName = "\(firstNameFB ?? "") \(lastNameFB ?? "")"
//                    self.photoUrl = photoUrl
//                    self.socialID = socialIdFB
//                    self.email = emailFB
//
//                }
//            }
//            Firestore.firestore().collection("users").whereField("email", isEqualTo: self.email ?? "").getDocuments(completion: { (snapshot, err) in
//                if let err = err {
//                    print(err)
//                }
//                if (snapshot?.isEmpty)! {
//                    self.saveInfoToFirestore()
//                }
//                else {
//                    let profileController = ProfilePageViewController()
//                    self.present(profileController, animated: true)
//                }
//            })
//
//        })
//    }
    
//    fileprivate func saveImageToFirebase() {
//
//        let filename = UUID().uuidString
//        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
//        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
//        ref.putData(imageData, metadata: nil, completion: {(_, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            print("finished Uploading image")
//            ref.downloadURL(completion: { (url, err) in
//                if let err = err {
//                    print(err)
//                    return
//                }
//                self.bindableIsRegistering.value = false
//                print("Download url of our image is:", url?.absoluteString ?? "")
//
//                let imageUrl = url?.absoluteString ?? ""
//                self.saveInfoToFirestore()
//            })
//        })
//    }
//
    //maybe add the completion shit
    
    
    //Need to save image to storage somehow
    
//    var fullName: String?
//    var school: String?
//    var age: Int?
//    var photoUrl: String?
//    var socialID: String?
//    var email: String?
    
//    fileprivate func saveInfoToFirestore() {
//        let uid = Auth.auth().currentUser?.uid ?? ""
//        let docData: [String: Any] =
//            ["Full Name": fullName ?? "",
//             "uid": uid,
//             "School": school ?? "",
//             "Age": age ?? 18,
//             "Bio": "",
//             "minSeekingAge": 18,
//             "maxSeekingAge": 50,
//             "email": email ?? "",
//             "fbid": socialID ?? "",
//             "ImageUrl1": photoUrl!]
//        let userAge = ["Age": age]
//        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
//
//            if let err = err {
//                print("there was an err",err)
//                return
//            }
//           let FBphoneController = FacebookPhoneController()
//
//            self.present(FBphoneController, animated: true)
//            let nameController = EnterNameController()
//            nameController.phone = "+18123234456"
//            self.present(nameController, animated: true)
//        }
//    }
