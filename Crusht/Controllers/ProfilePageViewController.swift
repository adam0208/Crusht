//
//  ProfilePageViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import GeoFire
import CoreLocation
import UserNotifications

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        profPicView.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

class ProfilePageViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CLLocationManagerDelegate {
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    let bottomStackView = ProfPageBottomStackView()
    let topStackView = ProfPageTopStackView()
    let profPicView = ProfPageMiddleView()
    //let profBttnView = ProfPageMidButtonView()
    
    @objc fileprivate func handleMatchByLocationBttnTapped() {
        let locationViewController = LocationMatchViewController()
        present(locationViewController, animated: true)
    }
    
    @objc fileprivate func handleFindCrushesTapped() {
        let transController = TransitionCrushesController()
        present(transController, animated: true)
    }
    
    @objc func handleSelectPhoto () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
        
    }
    
    @objc func handleSeniorFive() {
        let seniorController = SeniorFiveTableViewController()
        let navController = UINavigationController(rootViewController: seniorController)
        present(navController, animated: true)
        
    }
    
    @objc func handleMessages() {
        let messageController = MessageController()
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
        
    }
    
    
    func didSaveSettings() {
        print("Notified of dismissal")
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeController did appear")
        // you want to kick the user out when they log out
        if Auth.auth().currentUser == nil {
            let loginController = LoginViewController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true)
        }
    }
    
    fileprivate var crushScore: CrushScore?
    
    fileprivate func setLabelText() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            if snapshot?.exists == true {
                guard let dictionary = snapshot?.data() else {return}
                self.crushScore = CrushScore(dictionary: dictionary)
                print(self.crushScore?.crushScore ?? 0)
                if (self.crushScore?.crushScore ?? 0) > 10 && (self.crushScore?.crushScore ?? 0) <= 50 {
                self.profPicView.greetingLabel.text = "You're on 🔥"
                }
                else if (self.crushScore?.crushScore ?? 0) > 50 && (self.crushScore?.crushScore ?? 0) <= 100 {
                    self.profPicView.greetingLabel.text = "You Must be Cute 😍"
                }
                else if (self.crushScore?.crushScore ?? 0) > 100 && (self.crushScore?.crushScore ?? 0) <= 200 {
                    self.profPicView.greetingLabel.text = "Don't Get Too Cocky Now 😎"
                }
                else if (self.crushScore?.crushScore ?? 0) > 200 && (self.crushScore?.crushScore ?? 0) <= 400 {
                    self.profPicView.greetingLabel.text = "Wish I Were Like You 😤"
                }
                else if (self.crushScore?.crushScore ?? 0) > 400 {
                    self.profPicView.greetingLabel.text = "Add Dating as a Skill on Your Resume"
                }

            }
            else {
                self.profPicView.greetingLabel.text = "Hey Good Lookin' 😊"
            }
        }
        
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
         
            print(locationManager.location?.coordinate.latitude as Any)
            print(locationManager.location?.coordinate.latitude as Any)
            print("We have your location!")
        }
        
        //setupGradientLayer()
        fetchCurrentUser()
        setLabelText()
        
        profPicView.layer.cornerRadius = 100

        profPicView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        topStackView.homeButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)

        profPicView.matchByLocationBttm.addTarget(self, action: #selector(handleMatchByLocationBttnTapped), for: .touchUpInside)
        profPicView.findCrushesBttn.addTarget(self, action: #selector(handleFindCrushesTapped), for: .touchUpInside)

        
        profPicView.selectPhotoButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.seniorFive.addTarget(self, action: #selector(handleSeniorFive), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setupLayout()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        userLat = locValue.latitude
        userLong = locValue.longitude
    }
    
    var userLat = Double()
    var userLong = Double()
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            //print(snapshot?.data())
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
            
            let geoFirestoreRef = Firestore.firestore().collection("users")
            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)

            geoFirestore.setLocation(location: CLLocation(latitude: self.userLat, longitude: self.userLong), forDocumentWithID: uid) { (error) in
                if (error != nil) {
                    print("An error occured", error!)
                } else {
                    print("Saved location successfully!")
                }
            }
            self.loadUserPhotos()
        }
    }
    
    let tippyTop: UIView = {
        let tT = UIView()
        tT.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tT.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        return tT
    }()
    
    var user: User?
    
    fileprivate func loadUserPhotos() {
        guard let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) else {return}
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
            self.profPicView.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //self.user?.imageUrl1
    }
    
    fileprivate func setupLayout () {
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, profPicView, bottomStackView])
        view.addSubview(overallStackView)
        
        overallStackView.axis = .vertical
        
        overallStackView.spacing = 12
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    

    
}
