//
//  ViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import JGProgressHUD
import CoreLocation
import GeoFire
import UserNotifications

class LocationMatchViewController: UIViewController, CardViewDelegate, CLLocationManagerDelegate {
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    fileprivate var crushScore: CrushScore?
    
    fileprivate func addCrushScore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        guard let cardUID = topCardView?.cardViewModel.uid  else {
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
                let docData: [String: Any] = ["CrushScore": (self.crushScore?.crushScore ?? 0 ) + 1]
                Firestore.firestore().collection("score").document(uid).setData(docData)
            }
            else {
                let docData: [String: Any] = ["CrushScore": 1]
                Firestore.firestore().collection("score").document(uid).setData(docData)
            }
        }
        
        Firestore.firestore().collection("score").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            if snapshot?.exists == true {
                guard let dictionary = snapshot?.data() else {return}
                self.crushScore = CrushScore(dictionary: dictionary)
                let cardDocData: [String: Any] = ["CrushScore": (self.crushScore?.crushScore ?? 0 ) + 2]
                Firestore.firestore().collection("score").document(cardUID).setData(cardDocData)
            }
            else {
                let cardDocData: [String: Any] = ["CrushScore": 1]
                Firestore.firestore().collection("score").document(cardUID).setData(cardDocData)
            }
        }
        
    }
    
    let bottomStackView = LocationMatchBottomButtonsStackView()
    let topStackView = LocationMatchTopStackView()
    let cardDeckView = UIView()
    
    var cardViewModels = [CardViewModel]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

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
        
        topStackView.homeButton.addTarget(self, action: #selector(handleHomeBttnTapped), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        setupLayout()
     
       
      
                                                                    
        topStackView.switchView.isUserInteractionEnabled = true
       
        
        bottomStackView.likeBttn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomStackView.reportButton.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        bottomStackView.disLikeBttn.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        topStackView.collegeOnlySwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        view.backgroundColor = .white
        fetchCurrentUser()
        //fetchUsersFromFirestore()
        //fetchUsersOnLoad()
        fetchUsersOnLoad()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        userLat = locValue.latitude
        userLong = locValue.longitude
    }
    
    var userLat = Double()
    var userLong = Double()
    
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
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
            
            self.fetchSwipes()
            //self.fetchUsersFromFirestore()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            print("Swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            // self.fetchUsersFromFirestore()
            self.fetchUsersOnLoad()
        }
    }
    
    @objc func handleHomeBttnTapped() {
        self.dismiss(animated: true)
    }
    
    fileprivate func setupFirestoreUserCards() {
        
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            
            cardView.cardViewModel = cardVM
            
            cardDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    var lastFetchedUser: User?
    let hud = JGProgressHUD(style: .dark)
    
    func fetchUsersFromFirestore() {
        
//        if topStackView.collegeOnlySwitch.isOn == true {
//            fetchSchoolUsersOnly()
//        }
//
//        else {
        
        hud.textLabel.text = "Fetching Users, hold tight :)"
        hud.show(in: view)
        hud.dismiss(afterDelay: 1)
        
        
        var radiusInt: Double?
        
        let minAge = user?.minSeekingAge ?? 18
        let maxAge = user?.maxSeekingAge ?? 50
        
        //put distance stuff here
        
        if (user?.maxDistance ?? 10) < 10 {
            radiusInt = 1
        }
        else {
            radiusInt = 5
        }
        
        let geoFirestoreRef = Firestore.firestore().collection("users")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        
        let userCenter = CLLocation(latitude: userLat, longitude: userLong)
        
        
        
        let radiusQuery = geoFirestore.query(withCenter: userCenter, radius: radiusInt!)
                
//        radiusQuery.observe(.documentEntered, with: { (key, location) in
//            print("The document with documentID '\(self.user?.uid ?? "fuck")' entered the search area and is at location '\(userCenter)'")
//        })
        
//        let query = Firestore.firestore().collection("users").whereField("Age", isGreaterThanOrEqualTo: minAge).whereField("Age", isLessThanOrEqualTo: maxAge)
        //order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        topCardView = nil
        //geoFirestore.do

//        radiusQuery.observe(.documentEntered) { (key, location) in
//            
//        }
//
        radiusQuery.observeReady {
              print("All initial data has been loaded and events have been fired!")
        }
        
            Firestore.firestore().collection("users").whereField("Age", isGreaterThanOrEqualTo: minAge).whereField("Age", isLessThanOrEqualTo: maxAge).getDocuments { (snapshot, err) in
                if let err = err {
                    print("failed to fetch user", err)
                    self.hud.textLabel.text = "Failed To Fetch user"
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2)
                    return
                }
                
                
                var previousCardView: CardView?
                
                snapshot?.documents.forEach({ (documentSnapshot) in
//                    radiusQuery.observe(.documentEntered) { (key, location) in
//                        geoFirestore.getCollectionReference()
                    let userDictionary = documentSnapshot.data()
                    let user = User(dictionary: userDictionary)
                    // if user.uid != Auth.auth().currentUser?.uid {
                    let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                    let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                    if isNotCurrentUser && hasNotSwipedBefore  {
                        let cardView = self.setupCardFromUser(user: user)
                       
                        previousCardView?.nextCardView = cardView
                        previousCardView = cardView
                        
                        if self.topCardView == nil {
                            self.topCardView = cardView
                        }
                    }
                    
        
                    
                    
                })
        }
    }
    
    var reportUID = String()
    
    var reportName = String()
    
    var reportEmail = String()
    
        
        //}
    @objc fileprivate func handleReport() {
        let reportController = ReportControllerViewController()
        reportController.reportEmail = topCardView?.cardViewModel.email ?? "1"
        reportController.reportUID = topCardView?.cardViewModel.uid ?? "1"
        reportController.reportName = topCardView?.cardViewModel.attributedString.string ?? ""
        reportController.uid = Auth.auth().currentUser!.uid
        
        let myBackButton = UIBarButtonItem()
        myBackButton.title = "👈"
        navigationItem.backBarButtonItem = myBackButton
        
        //let navigatoinController = UINavigationController(rootViewController: reportController)
        navigationController?.pushViewController(reportController, animated: true)
    }

    
    fileprivate func fetchSchoolUsersOnly() {
        Firestore.firestore().collection("users").whereField("School", isEqualTo: user?.school ?? "jjjjj").getDocuments { (snapshot, err) in
            if let err = err {
                print("failed to fetch user", err)
                self.hud.textLabel.text = "Failed To Fetch user"
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2)
                return
            }
            
            self.topCardView = nil
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                // if user.uid != Auth.auth().currentUser?.uid {
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                if isNotCurrentUser && hasNotSwipedBefore  {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
                
            })
            
        }
    }
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        
        saveSwipeToFireStore(didLike: 1)
        
        addCrushScore()
        
        performSwipeAnimation(translation: 700, angle: 15)
        
    }
    
    fileprivate func saveSwipeToFireStore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let cardUID = topCardView?.cardViewModel.uid  else {
            return
        }
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe doc", err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("failed to save swipe", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                    print("Success")
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print("Error", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                    print("Success saved swipe SETDATA")
                }
            }
        }
        
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        
        print("Match detection")
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch doc for card user", err)
                return
            }
            guard let data = snapshot?.data() else {return}
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                
                print("we have a match!")
                Firestore.firestore().collection("users").document(cardUID).getDocument(completion: { (snapshot, err) in
                    if let err = err {
                        print("Error getting match", err)
                        return
                    }
                guard let userDictionary = snapshot?.data() else {return}
                let user = User(dictionary: userDictionary)
                
                let docData: [String: Any] = ["uid": cardUID, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!
                ]
                //this is for message controller
                Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                self.presentMatchView(cardUID: cardUID)
                })
            }
        }
        
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        matchView.sendMessageButton.addTarget(self, action: #selector(handleMessageButtonTapped), for: .touchUpInside)
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    @objc func handleDislike() {
        saveSwipeToFireStore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    @objc fileprivate func handleMessageButtonTapped() {
        let profileController = ProfilePageViewController()
        present(profileController, animated: true)
        let messageController = MessageController()
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
//        self.reportName = user.name ?? "1"
//        self.reportUID = user.uid ?? "1"
//        self.reportEmail = user.email ?? "1"
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        //userDetailsController.view.backgroundColor = .purple
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    @objc fileprivate func handleRefresh() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    //func bellow handles fetchusers on load -little improv
    fileprivate func fetchUsersOnLoad() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
        
    }
    
    fileprivate func fetchSchoolUsersCall() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchSchoolUsersOnly()
        
    }
    
    //MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        
        view.backgroundColor = .white
        
        cardDeckView.layer.cornerRadius = 40
        cardDeckView.clipsToBounds = true
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomStackView])
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    
    @objc fileprivate func switchValueDidChange() {
        
        if topStackView.collegeOnlySwitch.isOn == true {
        fetchSchoolUsersCall()
        }
        else{
            
            fetchUsersOnLoad()
            
            
        }
    }
    
    
 
}
