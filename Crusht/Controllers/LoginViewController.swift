//
//  LoginViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/6/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import FacebookLogin
import FBSDKLoginKit
import FacebookCore
import FBSDKCoreKit
import SDWebImage


class LoginViewController: UIViewController {
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var delegate: LoginControllerDelegate?

    let Text: UILabel = {
        let label = UILabel()
     
        label.text = "Wanna"
        label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
  

    
    let LoginBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in with Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()

    
    
    let FBLoginBttn: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Log in with Facebook", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        return button
    }()
    
   
    
    let phoneLoginBttn: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Log in with Phone", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLogin () {
        let phoneNumberViewController = PhoneNumberViewController()
        //navigationController?.pushViewController(phoneNumberViewController, animated: true)
        present(phoneNumberViewController, animated: true)
}
    let registrationViewModel = RegistrationViewModel()
    let registeringHUD = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleRegister() {
        print("Register our User in Firebase Auth")
        let profilePageViewController = ProfilePageViewController()
        registrationViewModel.performRegistration { [weak self] (err) in
            if let err = err {
                self?.showHUDWithError(error: err)
                return
            }
            self?.present(profilePageViewController, animated: true)
        }
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self)  { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print("cccccccccccccccccccccccccccccccccccccc",error)
            case .cancelled:
                print("User cancelled login.")
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Logged in!")
                self.performRegistration()
            }
            
        }
    }
    
    
    fileprivate func performRegistration() {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, err) in
            if let err = err {
                print("There was an error bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", err)
                
                return
            }
            
            print("Succesfully authenticated with Firebase.")
            self.fetchFacebookUser()
        }
    }
    
    fileprivate func goToProfilePage() {
        let profController = ProfilePageViewController()
        present(profController, animated: true)
    }
    
    fileprivate func fetchFacebookUser() {
        let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    let firstNameFB = responseDictionary["first_name"] as? String
                    let lastNameFB = responseDictionary["last_name"] as? String
                    let socialIdFB = responseDictionary["id"] as? String
                    let genderFB = responseDictionary["gender"] as? String
                    let emailFB = responseDictionary["email"] as? String
                    let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
                    let photoData = pictureUrlFB!["data"] as? [String:Any]
                    let photoUrl = photoData!["url"] as? String
                    
                    print(firstNameFB ?? "", lastNameFB ?? "", socialIdFB ?? "", genderFB ?? "", photoUrl ?? "")
                    
                    self.fullName = "\(firstNameFB ?? "") \(lastNameFB ?? "")"
                    self.photoUrl = photoUrl
                    self.socialID = socialIdFB
                    self.email = emailFB

                }
            }
            Firestore.firestore().collection("users").whereField("email", isEqualTo: self.email ?? "").getDocuments(completion: { (snapshot, err) in
                if let err = err {
                    print(err)
                }
                if (snapshot?.isEmpty)! {
                    self.saveInfoToFirestore()
                }
                else {
                    let profileController = ProfilePageViewController()
                    self.present(profileController, animated: true)
                }
            })
            
        })
    }
    
    fileprivate func saveImageToFirebase() {
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: {(_, err) in
            if let err = err {
                print(err)
                return 
            }
            print("finished Uploading image")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    print(err)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore()
            })
        })
    }
    
    //maybe add the completion shit
    
    
    //Need to save image to storage somehow
    
    var fullName: String?
    var school: String?
    var age: Int?
    var photoUrl: String?
    var socialID: String?
    var email: String?
    
    fileprivate func saveInfoToFirestore() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] =
            ["Full Name": fullName ?? "",
             "uid": uid,
             "School": school ?? "",
             "Age": age ?? 18,
             "Bio": "",
             "minSeekingAge": 18,
             "maxSeekingAge": 50,
             "email": email ?? "",
             "fbid": socialID ?? "",
             "ImageUrl1": photoUrl!]
        //let userAge = ["Age": age]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            
            if let err = err {
                print("there was an err",err)
                return
            }
//            let FBphoneController = FacebookPhoneController()
//
//            self.present(FBphoneController, animated: true)
            let FBPhoneController = FacebookPhoneController()
            FBPhoneController.fbid = self.socialID ?? ""
            self.present(FBPhoneController, animated: true)
        }
    }
    
        fileprivate func showHUDWithError(error: Error) {
            registeringHUD.dismiss()
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Failed registration"
            hud.detailTextLabel.text = error.localizedDescription
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 3)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientLayer()
        
        setupLayout()
    }
    
    let goToRegisterBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Not a user, Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleGoToLogin() {
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
        
    }
    
    fileprivate func setupLayout () {
        navigationController?.isNavigationBarHidden = true
        
        let logoImage = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/3))
        logoImage.image = #imageLiteral(resourceName: "CrushtLogoLiam")
        logoImage.contentMode = .scaleAspectFit
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        
        view.addSubview(Text)
        
        let overallStackView = UIStackView(arrangedSubviews: [logoImage, Text, phoneLoginBttn, UIView(), FBLoginBttn])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
                overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
                overallStackView.isLayoutMarginsRelativeArrangement = true
                overallStackView.layoutMargins = .init(top: -40, left: 30, bottom: 80, right: 30)
                overallStackView.spacing = 10
       
//        Text.anchor(top: overallStackView.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
       
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
