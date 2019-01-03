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


class LoginViewController: UIViewController {
    
    var delegate: LoginControllerDelegate?

   
    
    let Text: UILabel = {
        let label = UILabel()
        //label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 20, height: 200)
        label.text = "Wanna know if a crush is mutual?"
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .black
        //label.numberOfLines = 0
        return label
    }()
  

    
    let LoginBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in with Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        //button.setTitleColor(.gray, for: .disabled)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()

    
    
    let FBLoginBttn: UIButton = {
//        let fbBttngradient = CAGradientLayer()
//        let lightBlue = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//        let darkBlue = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
//        fbBttngradient.colors = [lightBlue.cgColor, darkBlue.cgColor]
//        fbBttngradient.locations = [0,1]
        
        let button = UIButton(type: .system)
        button.setTitle("Log in with Facebook", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = .blue
        //button.layer.addSublayer(fbBttngradient)
        //fbBttngradient.frame = button.bounds
        //button.setTitleColor(.gray, for: .disabled)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLogin () {
        let enterInfoViewController = EnterInfoViewController()
        present(enterInfoViewController, animated: true)
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
    
//    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()) {
//
//    }

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
            let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
            let photoData = pictureUrlFB!["data"] as? [String:Any]
            let photoUrl = photoData!["url"] as? String
            print(firstNameFB ?? "", lastNameFB ?? "", socialIdFB ?? "", genderFB ?? "", photoUrl ?? "")
            let uid = Auth.auth().currentUser?.uid ?? ""
            let name = "\(firstNameFB ?? "") \(lastNameFB ?? "")"
            let docData: [String: Any] =
                ["Full Name": name,
                 "uid": uid,
                 "School": "N/A",
                 "Age": 1,
                 "Bio": "",
                 "minSeekingAge": 18,
                 "maxSeekingAge": 50,
                 "ImageUrl1": pictureUrlFB as Any]
            //let userAge = ["Age": age]
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                //self.bindableIsRegistering.value = false
                if let err = err {
                    print("hahahaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",err)
                    return
                }
               let profileViewController = ProfilePageViewController()
                self.present(profileViewController, animated: true)
            }
            }
        }
    })
}
    
//    fileprivate func fuchFacebookUser() {
//
//        let graphRequestConnection = FBSDKGraphRequestConnection()
//        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture.type(large)"], accessToken: FBSDKAccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
//        graphRequestConnection.add(graphRequest, completion: { (httpResponse, result) in
//            switch result {
//            case .success(response: let response):
//
//                guard let responseDict = response.dictionaryValue else { print("Error"); return }
//
//                let json = JSON(responseDict)
//                self.name = json["name"].string
//                self.email = json["email"].string
//                guard let profilePicture = json["picture"]["data"]["url"].string else {print("error getting prof pic"); return }
//                guard let url = URL(string: profilePicture) else { print("Failed to fetch user"); return }
//
//                URLSession.shared.dataTask(with: url) { (data, response, err) in
//                    if err != nil {
//                        guard let err = err else {print("Failed Fetching User"); return }
//                        print("Failed Fetching User");
//                        return
//                    }
//                    guard let data = data else { print("failed to fetch user"); return }
//                    self.profileImage = UIImage(data: data)
//                    self.saveUserIntoFirebaseDatabase()
//
//                    }.resume()
//
//                break
//            case .failed(let err):
//                print("There was an error");
//                break
//            }
//        })
//        graphRequestConnection.start()
//
//    }

    
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
        logoImage.image = #imageLiteral(resourceName: "CrushTLogoIcon")
        logoImage.contentMode = .scaleAspectFit
        
        let overallStackView = UIStackView(arrangedSubviews: [logoImage, UIView(), Text, UIView(), FBLoginBttn, UIView(), LoginBttn])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
                overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
                overallStackView.isLayoutMarginsRelativeArrangement = true
                overallStackView.layoutMargins = .init(top: 0, left: 30, bottom: 80, right: 30)
                overallStackView.spacing = 10
        
       
    }
    
    
//    fileprivate func setupLayout() {
//
//        let overallStackView = UIStackView(arrangedSubviews: [topStackView, middleStackView, bottomStackView])
//        overallStackView.axis = .vertical
//
//        view.addSubview(overallStackView)
//
//        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
//        overallStackView.isLayoutMarginsRelativeArrangement = true
//        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
//
//    }
//
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
    let fbBttngradient = CAGradientLayer()
    
    fileprivate func FBbuttongradiant() {
        let lightBlue = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        let darkBlue = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        fbBttngradient.colors = [lightBlue.cgColor, darkBlue.cgColor]
        fbBttngradient.locations = [0,1]
        FBLoginBttn.layer.addSublayer(fbBttngradient)
        fbBttngradient.frame = FBLoginBttn.bounds
    
    }
    
}
