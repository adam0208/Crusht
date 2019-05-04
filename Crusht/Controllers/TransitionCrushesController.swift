////
////  TransitionCrushesController.swift
////  Crusht
////
////  Created by William Kelly on 1/21/19.
////  Copyright © 2019 William Kelly. All rights reserved.
////
//
//import UIKit
//import Firebase
//import JGProgressHUD
//import FacebookCore
//import FacebookLogin
//import CoreLocation
//import Contacts
//
//class TransitionCrushesController: UIViewController, CLLocationManagerDelegate {
//    
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.isNavigationBarHidden = true
//    }
//    var user: User?
////
//    
//    let Text: UILabel = {
//        let label = UILabel()
//        
//        label.text = "Find Crushes Via..."
//        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
//        label.textAlignment = .center
//        label.adjustsFontSizeToFitWidth = true
//
//        label.textColor = .black
//        return label
//    }()
//    
//    let privacyText: UILabel = {
//        let label = UILabel()
//        
//        label.text = "If one of your contacts doesn't have Crusht and you heart them, an anonymous message will be sent to their device informing them that \"someone\" has a crush on them."
//        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
//        label.textAlignment = .center
//        label.adjustsFontSizeToFitWidth = true
//        label.numberOfLines = 0
//        
//        label.textColor = .black
//        return label
//    }()
//    
//    let findCrushesThroughContacts: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Your Contacts", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//
//        
//        button.layer.cornerRadius = 22
//        
//        button.addTarget(self, action: #selector(handleContacts), for: .touchUpInside)
//        return button
//    }()
//    
//    let findCrushesThroughSchool: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Your School", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        
//        button.layer.cornerRadius = 22
//        
//        button.addTarget(self, action: #selector(handleSchool), for: .touchUpInside)
//        return button
//    }()
//    
//    let findCrushesThroughVenue: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Venues Near You", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 0.7448918819, green: 0, blue: 0.7210326791, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//        
//        
//        button.layer.cornerRadius = 22
//        
//        button.addTarget(self, action: #selector(handleVenue), for: .touchUpInside)
//        return button
//    }()
//    
//    
//    let findCrushesThroughFacebook: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Facebook Friends", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//
//        
//        button.layer.cornerRadius = 22
//        
//        button.addTarget(self, action: #selector(handleFacebook), for: .touchUpInside)
//        return button
//    }()
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//        userLat = locValue.latitude
//        userLong = locValue.longitude
//    
//    }
//    
//    var userLat = Double()
//    var userLong = Double()
//    
//     let locationManager = CLLocationManager()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.locationManager.requestAlwaysAuthorization()
//        
//        // For use in foreground
//        self.locationManager.requestWhenInUseAuthorization()
//        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//            
//            print(locationManager.location?.coordinate.latitude as Any)
//            print(locationManager.location?.coordinate.latitude as Any)
//            print("We have your location!")
//        }
//        
//        //fetchCurrentUser()
//        setupGradientLayer()
//        navigationController?.isNavigationBarHidden = true
//        let stack = UIStackView(arrangedSubviews: [Text, findCrushesThroughContacts,findCrushesThroughSchool,findCrushesThroughFacebook,findCrushesThroughVenue, privacyText])
//        view.addSubview(stack)
//     
//        
//        stack.axis = .vertical
//        
//        let padding = view.bounds.height/9
//        
//        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: padding, left: 30, bottom: padding, right: 30))
//        
//        stack.spacing = 20
//        
//       
//    }
//  
//    private func showSettingsAlert() {
//        let alert = UIAlertController(title: "Enable Contacts", message: "Crusht requires access to Contacts to proceed. We use your contacts to help you find your match. WE DON'T STORE YOUR CONTACTS IN OUR DATABASE. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
//            
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
//            return
//        })
//        present(alert, animated: true)
//    }
//    
//    private func showSettingsAlert2() {
//        let alert = UIAlertController(title: "Enable Location", message: "Crusht would like to use your location to match you with nearby users.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
//            
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
//            return
//        })
//        present(alert, animated: true)
//    }
//    
//    @objc fileprivate func handleContacts() {
//        let store = CNContactStore()
//        switch CNContactStore.authorizationStatus(for: .contacts) {
//            
//        case .authorized:
//            let contactsController = FindCrushesTableViewController()
//            let myBackButton = UIBarButtonItem()
//            contactsController.user = user
//            
//            myBackButton.title = "👈"
//            navigationItem.backBarButtonItem = myBackButton
//            navigationController?.pushViewController(contactsController, animated: true)
//        case .denied:
//            showSettingsAlert()
//        case .restricted, .notDetermined:
//            store.requestAccess(for: .contacts) { granted, error in
//                if granted {
//                    let contactsController = FindCrushesTableViewController()
//                    let myBackButton = UIBarButtonItem()
//                    contactsController.user = self.user
//                    
//                    myBackButton.title = "👈"
//                   self.navigationItem.backBarButtonItem = myBackButton
//                    self.navigationController?.pushViewController(contactsController, animated: true)
//                } else {
//                    DispatchQueue.main.async {
//                        self.showSettingsAlert()
//                    }
//                }
//            }
//        }
//      
//    }
//    
//    @objc fileprivate func handleSchool() {
//        let schoolController = SchoolCrushController()
//        schoolController.user = user
//        let myBackButton = UIBarButtonItem()
//        myBackButton.title = "👈"
//        navigationItem.backBarButtonItem = myBackButton
//        navigationController?.pushViewController(schoolController, animated: true)
//    }
//    
//    let hud = JGProgressHUD(style: .dark)
//    
//    @objc fileprivate func handleVenue() {
//        
//        if CLLocationManager.locationServicesEnabled() {
//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied:
//                showSettingsAlert2()
//            case .authorizedAlways, .authorizedWhenInUse:
//                let venueControlla = BarsTableView()
//                venueControlla.user = user
//              venueControlla.userLat = userLat
//                venueControlla.userLong = userLong
//                let myBackButton = UIBarButtonItem()
//                myBackButton.title = "👈"
//                navigationItem.backBarButtonItem = myBackButton
//                navigationItem.title = "Select to Check Venue"
//                navigationController?.pushViewController(venueControlla, animated: true)
//            }
//        } else {
//            self.showSettingsAlert2()
//        }
//
//    }
//    
//      let fbcontroller = FacebookCrushController()
//    
//    @objc fileprivate func handleFacebook() {
//    
//        if user?.fbid == "" {
//           // loginFB()
//        }
//        else {
//            let myBackButton = UIBarButtonItem()
//            myBackButton.title = "👈"
//            fbcontroller.user = user
//            navigationItem.backBarButtonItem = myBackButton
//        navigationController?.pushViewController(fbcontroller, animated: true)
//        }
//    }
//    
////    fileprivate func loginFB() {
////        let loginManager = LoginManager()
////        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self)  { (loginResult) in
////            switch loginResult {
////            case .failed(let error):
////                print("cccccccccccccccccccccccccccccccccccccc",error)
////            case .cancelled:
////                print("User cancelled login.")
////            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
////                print("Logged in!")
////                self.fetchFBid()
////            }
////        }
////    }
//    var FBID = String()
////    fileprivate func fetchFBid() {
////        let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
////        req.start({ (connection, result) in
////            switch result {
////            case .failed(let error):
////                print(error)
////            case .success(let graphResponse):
////                if let responseDictionary = graphResponse.dictionaryValue {
////                    print(responseDictionary)
////                    
////                    let socialIdFB = responseDictionary["id"] as? String
////                    print(socialIdFB!)
////                    
////                    self.FBID = socialIdFB!
////                    
////                    self.handleSaveFBID()
////                }
////            }
////        })
////    }
////    
//    fileprivate func handleSaveFBID() {
//        
//        guard let uid = Auth.auth().currentUser?.uid else { return}
//        let docData: [String: Any] = [
//            "uid": uid,
//            "Full Name": user?.name ?? "",
//            "ImageUrl1": user?.imageUrl1 ?? "",
//            "ImageUrl2": user?.imageUrl2 ?? "",
//            "ImageUrl3": user?.imageUrl3 ?? "",
//            "Age": user?.age ?? 23,
//            "Birthday": user?.birthday ?? "",
//            "School": user?.school ?? "",
//            "Bio": user?.bio ?? "",
//            "minSeekingAge": user?.minSeekingAge ?? 18,
//            "maxSeekingAge": user?.maxSeekingAge ?? 50,
//            "maxDistance": user?.maxDistance ?? 5,
//            "email": user?.email ?? "",
//            "fbid": FBID,
//            "PhoneNumber": user?.phoneNumber ?? "",
//            "deviceID": Messaging.messaging().fcmToken ?? ""
//        ]
//        
//        Firestore.firestore().collection("users").document(uid).setData(docData) { (err)
//            in
//            //hud.dismiss()
//            if let err = err {
//                print("Failed to retrieve user settings", err)
//                return
//            }
//            self.fbcontroller.user = self.user
//            self.navigationController?.pushViewController(self.fbcontroller, animated: true)
//        }
//    }
//
//    let gradientLayer = CAGradientLayer()
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        gradientLayer.frame = view.bounds
//        
//    }
//    
//    fileprivate func setupGradientLayer() {
//        
//        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
//        // make sure to user cgColor
//        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        gradientLayer.locations = [0, 1]
//        view.layer.addSublayer(gradientLayer)
//        gradientLayer.frame = view.bounds
//    }
//    
//}
//
//
//
