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

import CoreLocation
import GeoFire
import UserNotifications

class LocationMatchViewController: UIViewController, CardViewDelegate, CLLocationManagerDelegate {
    var cardViewModels = [CardViewModel]()
    var topCardView: CardView?
    
    private var crushScore: CrushScore?
    var userLat = Double()
    var userLong = Double()
    var user: User?
    var sexPref = String()
    var userAge = Int()
    var swipes = [String: Int]()
    var phoneSwipes = [String: Int]()
    var lastFetchedUser: User?
    var radiusInt = Double()
    var isRightSex = Bool()
    
    var reportUID = String()
    var reportName = String()
    var reportEmail = String()
    
    var lastFetchedDocument: QueryDocumentSnapshot? = nil
    var fetchingMoreUsers = false
    var fetchedAllUsers = false
    
    let locationManager = CLLocationManager()
    
    // MARK: - Life Cicle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        
        }
        
        topStackView.homeButton.addTarget(self, action: #selector(handleHomeBttnTapped), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        setupLayout()
                                                     
        bottomStackView.likeBttn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomStackView.reportButton.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        bottomStackView.disLikeBttn.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        topStackView.collegeOnlySwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        view.backgroundColor = .white
        fetchCurrentUser(user: user!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        refreshLabel.isHidden = true
        navigationController?.isNavigationBarHidden = true
        
        topCardView = nil
        lastFetchedDocument = nil
        fetchedAllUsers = false
    }
    
    // MARK: - Logic
    
    fileprivate func addCrushScore() {
        guard let uid = Auth.auth().currentUser?.uid, let cardUID = topCardView?.cardViewModel.uid else {
            return
        }
        
        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
            if err != nil {
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
            if err != nil {
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

    fileprivate func fetchCurrentUser(user: User) {
        self.refreshLabel.isHidden = true
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
            self.userAge = user.age ?? 18
            
            let geoFirestoreRef = Firestore.firestore().collection("users")
            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
            
            geoFirestore.setLocation(location: CLLocation(latitude: self.userLat, longitude: self.userLong), forDocumentWithID: uid) { (error) in
                if error == nil {
                    print("Saved location successfully!")
                }
            }
            self.fetchSwipes()
        }
    }
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            // self.fetchUsersFromFirestore()
            self.fetchPhoneSwipes()
            
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
    
    fileprivate func fetchPhoneSwipes() {
        let phoneID = user?.phoneNumber ?? ""
        
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.phoneSwipes = data
            // Do fetchusers on load instead
            self.fetchUsersOnLoad()
        }
    }
    
    func fetchMoreNearbyUsers() {
        let minAge = user?.minSeekingAge ?? 18
        let maxAge = user?.maxSeekingAge ?? 50
        
        radiusInt = (Double(user?.maxDistance ?? 10)/1.609344)
        
        let geoFirestoreRef = Firestore.firestore().collection("users")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        let userCenter = CLLocation(latitude: userLat, longitude: userLong)
        
        let radiusQuery = geoFirestore.query(withCenter: userCenter, radius: radiusInt)

        let _ = radiusQuery.observe(.documentEntered) { (key, location) in
             if let key = key, location != nil {
                Firestore.firestore().collection("users").whereField("uid", isEqualTo: key).whereField("Age", isGreaterThanOrEqualTo: minAge).whereField("Age", isLessThanOrEqualTo: maxAge).limit(to: 5).getDocuments { (snapshot, err) in
                    if err != nil {
                        self.refreshLabel.text = "Failed to Fetch User"
                        return
                    }
                    
                    var previousCardView: CardView?
                    snapshot?.documents.forEach({ (documentSnapshot) in
                        let userDictionary = documentSnapshot.data()
                        let user = User(dictionary: userDictionary)
                        let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                        let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                        let hasNotSwipedPhoneBefore = self.phoneSwipes[user.phoneNumber!] == nil
                        let isInRadius = user.uid == key
                        
                        let isEnabled = user.g != "7zzzzzzzzz"
                        
                        if self.sexPref == "Female" {
                            self.isRightSex = user.gender == "Female" || user.gender == "Other"
                        }
                        else if self.sexPref == "Male" {
                            self.isRightSex = user.gender == "Male" || user.gender == "Other"
                        }
                        else {
                            self.isRightSex = user.age ?? 18 > 17
                        }
                        
                        if isNotCurrentUser && hasNotSwipedBefore && hasNotSwipedPhoneBefore && isInRadius && isEnabled && self.isRightSex {
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
        }
       self.refreshLabel.isHidden = false
    }
    
    @objc fileprivate func handleReport() {
        let reportController = ReportControllerViewController()
        reportController.reportPhoneNumebr = topCardView?.cardViewModel.phone ?? "1"
        reportController.reportUID = topCardView?.cardViewModel.uid ?? "1"
        reportController.reportName = topCardView?.cardViewModel.attributedString.string ?? ""
        reportController.uid = Auth.auth().currentUser!.uid
        
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        navigationItem.backBarButtonItem = myBackButton
        navigationController?.pushViewController(reportController, animated: true)
    }
    
    fileprivate func fetchMoreSchoolUsers() {
        guard !fetchingMoreUsers else { return }
        fetchingMoreUsers = true
        var query: Query
        if let lastFetchedDocument = lastFetchedDocument {
            query = Firestore.firestore().collection("users").whereField("School", isEqualTo: user?.school ?? "jjjjj").start(afterDocument: lastFetchedDocument).limit(to: 15)
        } else {
            query = Firestore.firestore().collection("users").whereField("School", isEqualTo: user?.school ?? "jjjjj").limit(to: 15)
        }
        
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print(err, "noooo")
                self.refreshLabel.text = "Failed to Fetch User \(err)"
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.documents.count == 0 {
                self.fetchedAllUsers = true
                return
            }
            
            var previousCardView = self.topCardView?.lastCardView
            
            self.lastFetchedDocument = snapshot.documents.last
            snapshot.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                
                let hasNotSwipedPhoneBefore = self.phoneSwipes[user.phoneNumber!] == nil
                let maxAge = user.age ?? 18  < (self.userAge + 5)
                let minAge = user.age ?? 18 > (self.userAge - 5)
                
                if self.sexPref == "Female" {
                    self.isRightSex = user.gender == "Female" || user.gender == "Other"
                }
                else if self.sexPref == "Male" {
                    self.isRightSex = user.gender == "Male" || user.gender == "Other"
                }
                else {
                    self.isRightSex = user.age ?? 18 > 17
                }
                
                if isNotCurrentUser && minAge && maxAge && hasNotSwipedBefore && hasNotSwipedPhoneBefore && self.isRightSex {
                    let cardView = self.setupCardFromUser(user: user)
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
            
            self.fetchingMoreUsers = false
            self.fetchMoreUsersIfNecessary()
        }
    }
    
    @objc func handleLike() {
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        performSwipeAnimation(translation: 700, angle: 15)
        fetchMoreUsersIfNecessary()
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
                print(err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            guard let data = snapshot?.data() else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                Firestore.firestore().collection("users").document(cardUID).getDocument(completion: { (snapshot, err) in
                    if err != nil {
                        return
                    }
                    guard let userDictionary = snapshot?.data() else {return}
                    let user = User(dictionary: userDictionary)
                    let docData: [String: Any] = ["uid": cardUID]
                    let otherDocData:  [String: Any] = ["uid": uid]
                    
                    Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: cardUID).getDocuments(completion: { (snapshot, err) in
                        if err != nil {
                            return
                        }
                        if (snapshot?.isEmpty)! {
                            Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                            Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
                        }
                    })
                    self.handleSend(cardUID: cardUID, cardName: user.name ?? "")
                })
            }
        }
    }
    
    @objc func handleSend(cardUID: String, cardName: String) {
        let properties = ["text": "We matched! This is an automated message."]
        sendAutoMessage(properties as [String : AnyObject], cardUID: cardUID, cardNAME: cardName)
    }
    
    fileprivate func sendAutoMessage(_ properties: [String: AnyObject], cardUID: String, cardNAME: String) {
        let toId = cardUID
        let fromId = Auth.auth().currentUser!.uid
        let toName = cardNAME
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": user?.name as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({values[$0] = $1})
        
        // Flip to id and from id to fix message controller query glitch
        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({otherValues[$0] = $1})
        
        // SOLUTION TO CURRENT ISSUE
        // if statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if err != nil {
                return
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if err != nil {
                        return
                    }
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if err != nil {
                            return
                        }
                        
                        snapshot?.documents.forEach({ (documentSnapshot) in
                            let document = documentSnapshot
                            if document.exists {
                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                            }
                            else{
                                print("DOC DOESN't exist yet")
                            }
                        })
                    })
                }
            } else {
                snapshot?.documents.forEach({ (documentSnapshot) in
                    let document = documentSnapshot
                    if document.exists {
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                        // Message row update fix
                        
                        // Sort a not to update from id stuff
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
                        
                        // Flip it
                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
                            if err != nil {
                                return
                            }
                            
                            snapshot?.documents.forEach({ (documentSnapshot) in
                                let document = documentSnapshot
                                if document.exists {
                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(otherValues)
                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: otherValues)
                                }
                            })
                        })
                    }
                })
            }
        })
        
        self.sendAutoMessageTWO(properties, cardNAME: user?.name ?? "", fromId: toId, toId: fromId, toName: toName)
    }
    
    fileprivate func sendAutoMessageTWO(_ properties: [String: AnyObject], cardNAME: String, fromId: String, toId: String, toName: String) {
        let toId = toId
        let fromId = fromId
        let toName = toName
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": user?.name as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({values[$0] = $1})
        
        // Flip to id and from id to fix message controller query glitch
        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({otherValues[$0] = $1})
        
        // SOLUTION TO CURRENT ISSUE
        // If statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if err != nil {
                return
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if err != nil {
                        return
                    }
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if err != nil {
                            return
                        }
                        snapshot?.documents.forEach({ (documentSnapshot) in
                            let document = documentSnapshot
                            if document.exists {
                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                            } else{
                                print("DOC DOESN't exist yet")
                            }
                        })
                    })
                }
            } else {
                snapshot?.documents.forEach({ (documentSnapshot) in
                    let document = documentSnapshot
                    if document.exists {
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                        // Message row update fix
                        
                        // Sort a not to update from id stuff
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
                        
                        // Flip it
                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
                            if err != nil {
                                return
                            }
                            
                            snapshot?.documents.forEach({ (documentSnapshot) in
                                let document = documentSnapshot
                                if document.exists {
                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(otherValues)
                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: otherValues)
                                }
                            })
                        })
                    }
                })
            }
        })
        
        self.presentMatchView(cardUID: fromId)
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        MessageController.sharedInstance?.didHaveNewMessage = true
    
        UIApplication.shared.applicationIconBadgeNumber = 1
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    @objc func handleDislike() {
        saveSwipeToFireStore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
        fetchMoreUsersIfNecessary()
    }
    
    private func fetchMoreUsersIfNecessary() {
        if topCardView?.nextCardView?.nextCardView == nil {
            if topStackView.collegeOnlySwitch.isOn {
                fetchMoreSchoolUsers()
            }
        }
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        
        cardView.fillSuperview()
        return cardView
    }
    
    @objc fileprivate func handleRefresh() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchSwipes()
    }
    
    // Func bellow handles fetchusers on load -little improv
    fileprivate func fetchUsersOnLoad() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchMoreNearbyUsers()
    }
    
    fileprivate func fetchSchoolUsersCall() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchMoreSchoolUsers()
    }
    
    @objc fileprivate func switchValueDidChange() {
        topCardView = nil
        lastFetchedDocument = nil
        fetchedAllUsers = false
        
        if topStackView.collegeOnlySwitch.isOn {
            fetchSchoolUsersCall()
        } else {
            fetchUsersOnLoad()
        }
    }
    
    //MARK: - CardViewDelegate
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        self.navigationItem.backBarButtonItem = myBackButton
        userDetailsController.cardViewModel = cardViewModel
        navigationController?.pushViewController(userDetailsController, animated: true)
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLat = locValue.latitude
        userLong = locValue.longitude
    }
    
    // MARK: - User Interface
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(refreshLabel)
        refreshLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        cardDeckView.layer.cornerRadius = 40
        cardDeckView.clipsToBounds = true
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.spacing = 8
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 8, right: 12)
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    
    let bottomStackView = LocationMatchBottomButtonsStackView()
    let topStackView = LocationMatchTopStackView()
    let cardDeckView = UIView()
    
    let refreshLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Hit ♻️ to load more crushes in your area!"
        label.numberOfLines = 0
        return label
    }()
    
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
}
