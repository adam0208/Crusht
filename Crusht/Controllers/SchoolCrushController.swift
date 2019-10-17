//
//  SchoolCrushController.swift
//  Crusht
//
//  Created by William Kelly on 1/9/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//
import UIKit
import Firebase

import CoreLocation
import SDWebImage
import GeoFire

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

protocol SchoolDelegate {
    func didSendNewMessage()
}

class SchoolCrushController: UITableViewController, UISearchBarDelegate, SettingsControllerDelegate, LoginControllerDelegate, UITabBarControllerDelegate {
    
    var fetchedAllUsers = false
    var fetchingMoreUsers = false
    var lastFetchedDocument: QueryDocumentSnapshot? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBar.prefersLargeTitles = true
        
        if UIApplication.shared.applicationIconBadgeNumber == 1 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
        }
  
        fetchedAllUsers = false
        lastFetchedDocument = nil
        schoolArray.removeAll()
        tableView.reloadData()
        fetchCurrentUser()
    }
    
    var schoolDelegate: SchoolDelegate?
    
    func didSaveSettings() {
        fetchedAllUsers = false
        lastFetchedDocument = nil
        schoolArray.removeAll()
        tableView.reloadData()
        fetchCurrentUser()
    }
    
    func didFinishLoggingIn() {
        fetchedAllUsers = false
        lastFetchedDocument = nil
        schoolArray.removeAll()
        tableView.reloadData()
        fetchCurrentUser()
    }
    
    //    CONTACTS EASILY DOABLE IF YOU GET USERS PHONE NUMBER
  
    fileprivate var crushScore: CrushScore?
    
    fileprivate func addCrushScore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let cardUID = crushScoreID
        
        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
            if let err = err {
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
    
    let animationView = AnimationView()
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        }
    }

   
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        
        
        //        navigationItem.leftItemsSupplementBackButton = true
        //        navigationItem.leftBarButtonItem?.title = "👈"
        //tableView.register(SchoolTableViewCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        //navigationItem.title = "School"
        tableView.register(SchoolTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCellId)
        
        let swipeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
        let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-30"), style: .plain, target: self, action: #selector(handleInfo))
        
        listenForMessages()
        navigationItem.rightBarButtonItems = [swipeButton, infoButton]
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search School"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
           
        
        // Setup the Scope Bar
        //self.searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        messageBadge.isHidden = true
        // Setup the search footer
        // tableView.tableFooterView = searchFooter
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        searchController.searchBar.barStyle = .black
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        tabBarController?.view.addSubview(animationView)
        animationView.fillSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
            self.animationView.removeFromSuperview()
        }
    }
    
    @objc fileprivate func handleInfo() {
        
        let infoView = InfoView()
        infoView.infoText.text = "Crush Classmates: Select the heart next to people at your school/alma mater. If they select the heart on your name as well, you'll be matched in the chats tab!"
        tabBarController?.view.addSubview(infoView)
        
          infoView.fillSuperview()
//        hud.textLabel.text = "Crush Classmates: Select the heart next people at your school/alma mater. If they select the heart on your name as well, you'll be matched in the chats tab!"
//        hud.show(in: navigationController!.view)
//        hud.dismiss(afterDelay: 5)
    }
    
    
    var sawMessage = Bool()
    
    @objc func handleMessages() {
        let messageController = MessageController()
        messageBadge.removeFromSuperview()
        sawMessage = true
        messageController.user = user
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
        //navigationController?.pushViewController(messageController, animated: true)
        
    }
    
    let messageBadge: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        label.backgroundColor = .red
        label.text = "!"
        return label
    }()

    
    fileprivate func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                    }
                    if (diff.type == .modified) {
                        self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
                        self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
                        UIApplication.shared.applicationIconBadgeNumber = 1
                    }
                    if (diff.type == .removed) {
                    }
                }
        }
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
        
    }
    
    @objc fileprivate func handleMatchByLocationBttnTapped() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                showSettingsAlert2()
            case .authorizedAlways, .authorizedWhenInUse:
                let locationViewController = LocationMatchViewController()
                locationViewController.user = user
                let navigationController = UINavigationController(rootViewController: locationViewController)
                present(navigationController, animated: true)
            }
        } else {
            showSettingsAlert2()
        }
        
        
        
    }
    
    
    private func showSettingsAlert2() {
        let alert = UIAlertController(title: "Enable Location", message: "Crusht would like to use your location to match you with nearby users.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            return
        })
        present(alert, animated: true)
    }
    
    var user: User?
    
    var schoolArray = [User]()
    
    var users = [User]()
    
    //search bar stuff
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        users = schoolArray.filter({( user : User) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
              
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
                return
            }
            guard let dictionary = snapshot?.data() else {return}
            
            self.user = User(dictionary: dictionary)
            if self.user?.phoneNumber == ""{
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
                return
        
            }
            else if self.user?.name == "" {
                let namecontroller = EnterNameController()
                namecontroller.phone = self.user?.phoneNumber ?? ""
                self.present(namecontroller, animated: true)
                return
              
            }
            
            //self.fetchSwipes()
            self.fetchSchool()
            }
      
    }
    
    //    var indexSchoolNames = [String]()
    //
    //    var indexSchoolDictionary = [String: [String]]()
    //
    //    var indexSchoolTitles = String()
    
    
    var isRightSex = Bool()
    
    var schoolUserDictionary = [String: User]()
    
    fileprivate func fetchSchool() {
        guard !fetchedAllUsers, !fetchingMoreUsers else { return }
        fetchingMoreUsers = true
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        
        let school = user?.school ?? "Your School"
        navigationItem.title = school
        var query: Query
        if let lastFetchedDocument = lastFetchedDocument {
            query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school).order(by: "Full Name").start(afterDocument: lastFetchedDocument).limit(to: 15)
        } else {
            query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school).order(by: "Full Name").limit(to: 15)
        }
        
        //chagne logic where gender variable is just the where field firebase thing
        query.getDocuments { (snapshot, err) in
            guard err == nil, let snapshot = snapshot else { return }
            
            if snapshot.documents.count == 0 {
                self.fetchedAllUsers = true
                self.fetchingMoreUsers = false
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                return
            }
            
            self.lastFetchedDocument = snapshot.documents.last
            snapshot.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let crush = User(dictionary: userDictionary)
                let isNotCurrentUser = crush.uid != Auth.auth().currentUser?.uid
                
                let sexPref = self.user?.sexPref
                if sexPref == "Female" {
                    self.isRightSex = crush.gender == "Female" || crush.gender == "Other"
                }
                else if sexPref == "Male" {
                    self.isRightSex = crush.gender == "Male" || crush.gender == "Other"
                }
                else {
                    self.isRightSex = crush.school == self.user?.school
                }
                
                let maxAge = crush.age < ((self.user?.age)! + 5)
                let minAge = crush.age > ((self.user?.age)! - 5)
                
                if isNotCurrentUser && minAge && maxAge && self.isRightSex {
                    //                    self.indexSchoolNames.append(String(crush.name!.prefix(1)))
                    //                    for indexSchoolName in self.indexSchoolNames {
                    //
                    //                        let nameKey = String(crush.name!.prefix(1))
                    //                        if var nameValues = self.indexSchoolDictionary[nameKey] {
                    //                            nameValues.append(indexSchoolName)
                    //                            self.indexSchoolDictionary[nameKey] = nameValues
                    //                        }
                    //                        else {
                    //                            self.indexSchoolDictionary[nameKey] = [indexSchoolName]
                    //                        }
                    //                    }
                    
                    
                    //                self.indexSchoolNames = [String](self.indexSchoolDictionary.keys)
                    //                self.indexSchoolNames = self.indexSchoolNames.sorted()
                    
                    self.schoolArray.append(crush)
                }
                
                
                //                let crushStuff = User(dictionary: userDictionary)
                //                if let crushPartnerId = crushStuff.crushPartnerId() {
                //                    self.schoolUserDictionary[crushPartnerId] = user
                //                    self.users = Array(self.schoolUserDictionary.values)
                //                }
                
                
                
            })
            
            DispatchQueue.main.async(execute: {
                self.fetchingMoreUsers = false
                self.tableView.reloadData()
            })
            
            self.fetchSwipes()
        }
        
    }
    
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return indexSchoolNames[section]
    //    }
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // 1
    //        return indexSchoolNames.count
    //    }
    //
    //
    //
    //    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        return indexSchoolNames
    //    }
    
    
    func hasTappedCrush(cell: UITableViewCell) {
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let crush = schoolArray[indexPathTapped.row]
        
        crushScoreID = crush.uid ?? ""
        
        let phoneString = crush.phoneNumber ?? ""
        
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        
        matchUID = phoneNoDash
        
        //tableView.reloadRows(at: [indexPathTapped], with: .fade)
        
        //cell.tintColor = .red
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1) {
            
            handleLike(cell: cell)
        }
        else {
            handleDislike(cell: cell)
        }
        
    }
    
    var crushScoreID = String()
    
    var matchUID = String()
    
    
    func saveSwipeToFireStore(didLike: Int) {
        
        let phoneID = user?.phoneNumber ?? ""
        
        let cardUID = matchUID
        
        let documentData = [cardUID: didLike]
        let otherDocData = [crushScoreID: didLike]
        
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("phone-swipes").document(phoneID).updateData(documentData) { (err) in
                    if let err = err {
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("phone-swipes").document(phoneID).setData(documentData) { (err) in
                    if let err = err {
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
            
            Firestore.firestore().collection("swipes").document(self.user?.uid ?? "").getDocument { (snapshot, err) in
                if let err = err {
                    return
                }
                if snapshot?.exists == true {
                    Firestore.firestore().collection("swipes").document(self.user?.uid ?? "").updateData(otherDocData) { (err) in
                        if let err = err {
                            return
                        }
                        if didLike == 1 {
                           print("great")
                        }
                    }
                } else {
                        print("Success saved swipe SETDATA")
                    }
                self.fetchSwipes()
        }

    }
}
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        
        
        Firestore.firestore().collection("phone-swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            guard let data = snapshot?.data() else {return}
            
            
            //guard let uid = Auth.auth().currentUser?.uid else {return}
            //Firestore.firestore()
            
            let phoneNumber = self.user?.phoneNumber ?? ""
            
            let hasMatched = data[phoneNumber] as? Int == 1
            if hasMatched {
                self.getCardUID(phoneNumber: cardUID)
            }
        }
    }
    
    fileprivate func getCardUID(phoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let phone = phoneNumber
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
            
            if let err = err {
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let cardUID = user.uid!
                
                Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, err) in
                    if let err = err {
                        return
                    }
                    let secondUserDictionary = snapshot?.data()
                    let secondUser = User(dictionary: secondUserDictionary!)
                    let otherDocData: [String: Any] = ["uid": uid, "Full Name": secondUser.name ?? "", "School": secondUser.school ?? "", "ImageUrl1": secondUser.imageUrl1!, "matchName": user.name ?? ""
                    ]
                    
                    let docData: [String: Any] = ["uid": cardUID, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!, "matchName": secondUser.name ?? ""
                    ]
                    
                    //this is for message controller
                    Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: cardUID).getDocuments(completion: { (snapshot, err) in
                        if let err = err {
                            return
                        }
                        
                        
                        if (snapshot?.isEmpty)! {
                            Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                            
                            
                            Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
                            
                            self.handleSend(cardUID: cardUID, cardName: user.name ?? "")
                            
                            
                        }
                        
                    })
                    
                })
                
                
                //                Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: uid).getDocuments(completion: { (snapshot, err) in
                //                    if let err = err {
                //                        print(err)
                //                    }
                //
                //                    if (snapshot?.isEmpty)! {
                //                        Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                //                        Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
                //                    }
                //                })
                
                
                
                
                
            })
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        let phoneID = user?.phoneNumber ?? ""
        
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            
            self.fetchMoreSwipes()
        }
    }
    
    var locationSwipes = [String: Int]()
    
    fileprivate func fetchMoreSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.locationSwipes = data
            // self.fetchUsersFromFirestore()
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                
            })
            
        }
        
    }
    
    @objc func handleSend(cardUID: String, cardName: String) {
        let properties = ["text": "We matched! This is an automated message."]
        sendAutoMessage(properties as [String : AnyObject], cardUID: cardUID, cardNAME: cardName)
    }
    
    fileprivate func sendAutoMessage(_ properties: [String: AnyObject], cardUID: String, cardNAME: String) {
        
        let toId = cardUID
        //let toDevice = user?.deviceID!
        let fromId = Auth.auth().currentUser!.uid
        
        let toName = cardNAME
        
        
        let timestamp = Int(Date().timeIntervalSince1970)
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": user?.name as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        //flip to id and from id to fix message controller query glitch
        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
        
        properties.forEach({otherValues[$0] = $1})
        
        
        //let ref = Firestore.firestore().collection("messages")
        
        
        //SOLUTION TO CURRENT ISSUE
        //if statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                return
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if let err = err {
                        return
                    }
                    //Firestore.firestore().collection("messages").addDocument(data: otherValues)
                    
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if let err = err {
                            return
                        }
                        
                        snapshot?.documents.forEach({ (documentSnapshot) in
                            
                            let document = documentSnapshot
                            if document.exists {
                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                                
                                //need to update the message collum for other user
                                //just flip toID and Fromi
                                
                                
                            }
                            else{
                                print("DOC DOESN't exist yet")
                            }
                        })
                    })
                }
            }
                
            else {
                
                snapshot?.documents.forEach({ (documentSnapshot) in
                    
                    let document = documentSnapshot
                    if document.exists {
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                        
                        
                        
                        //message row update fix
                        
                        //sort a not to update from id stuff
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
                        
                        //flip it
                        
                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
                            if let err = err {
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
          //      self.presentMatchView(cardUID: toId)
        self.sendAutoMessageTWO(properties, cardNAME: user?.name ?? "", fromId: toId, toId: fromId, toName: toName)
        
    }
    
    fileprivate func sendAutoMessageTWO(_ properties: [String: AnyObject], cardNAME: String, fromId: String, toId: String, toName: String) {
        
        let toId = toId
        //let toDevice = user?.deviceID!
        let fromId = fromId
        
        let toName = toName
        
        //        Firestore.firestore().collection("users").document(fromId).getDocument { (snapshot, err) in
        //            if let err = err {
        //                print(err)
        //            }
        //            let userFromNameDictionary = snapshot?.data()
        //            let userFromName = User(dictionary: userFromNameDictionary!)
        //            self.fromName = userFromName.name ?? "loser"
        //            print(userFromName.name ?? "hi ho yo")
        //        }
        //
        //        print(fromName, "Fuck you bro")
        
        let timestamp = Int(Date().timeIntervalSince1970)
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": user?.name as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        //flip to id and from id to fix message controller query glitch
        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
        
        properties.forEach({otherValues[$0] = $1})
        
        
        //let ref = Firestore.firestore().collection("messages")
        
        
        //SOLUTION TO CURRENT ISSUE
        //if statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                return
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if let err = err {
                        return
                    }
                    //Firestore.firestore().collection("messages").addDocument(data: otherValues)
                    
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if let err = err {
                            return
                        }
                        
                        snapshot?.documents.forEach({ (documentSnapshot) in
                            
                            let document = documentSnapshot
                            if document.exists {
                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                                
                                //need to update the message collum for other user
                                //just flip toID and Fromi
                                
                                
                            }
                            else{
                                print("DOC DOESN't exist yet")
                            }
                        })
                    })
                }
            }
                
            else {
                
                snapshot?.documents.forEach({ (documentSnapshot) in
                    
                    let document = documentSnapshot
                    if document.exists {
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                        
                        
                        
                        //message row update fix
                        
                        //sort a not to update from id stuff
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
                        
                        //flip it
                        
                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
                            if let err = err {
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
    
    let messageController = MessageController()
    
    func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
        self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
        UIApplication.shared.applicationIconBadgeNumber = 1
       MessageController.sharedInstance?.didHaveNewMessage = true

        self.tabBarController?.view.addSubview(matchView)
        matchView.bringSubviewToFront(view)
        matchView.fillSuperview()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isFiltering() {
                return users.count
            }
            if schoolArray.isEmpty {
                return 1
            }
            return schoolArray.count
            
        } else if section == 1 && fetchingMoreUsers {
            return 1
        }
        
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if indexPath.row == schoolArray.count - 1 && !isFiltering() {
            fetchSchool()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellL = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SchoolTableViewCell
            cellL.link = self
            
            if !schoolArray.isEmpty {
                if isFiltering() {
                    let crush = users[indexPath.row]
                    cellL.textLabel?.text = crush.name
                    let imageUrl = crush.imageUrl1!
                    let url = URL(string: imageUrl)
                    SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                        cellL.profileImageView.image = image
                    }
                } else {
                    let crush = schoolArray[indexPath.row]
                    cellL.textLabel?.text = crush.name
                    let imageUrl = crush.imageUrl1!
                    let url = URL(string: imageUrl)
                    SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                        cellL.profileImageView.image = image
                    }
                }
                
                let crush = schoolArray[indexPath.row]
                let hasLiked = swipes[crush.phoneNumber ?? ""] == 1
                let swipeLike = locationSwipes[crush.uid ?? ""] == 1
                
                if hasLiked || swipeLike {
                    cellL.accessoryView?.tintColor = .red
                    hasFavorited = true
                } else {
                    cellL.accessoryView?.tintColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.schoolArray.isEmpty {
                        cellL.textLabel?.text = "No classmates to show 😔"
                        cellL.accessoryView?.isHidden = true
                    }
                }
            }
            return cellL
        } else { // Set up loading cell
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: loadingCellId, for: indexPath) as! LoadingCell
            loadingCell.spinner.startAnimating()
            return loadingCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let crush = schoolArray[indexPath.row]
        
        guard let profUID = crush.uid else {
            return
        }
        //
        //        let userDetailsController = UserDetailsController()
        //        //userDetailsController.view.backgroundColor = .purple
        //        userDetailsController.cardViewModel =
        //        present(userDetailsController, animated: true)
        Firestore.firestore().collection("users").document(profUID).getDocument(completion: { (snapshot, err) in
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else {return}
            
            var user = User(dictionary: dictionary)
            user.uid = profUID
            let userDetailsController = UserDetailsController()
            
            let myBackButton = UIBarButtonItem()
            myBackButton.title = " "
           self.navigationItem.backBarButtonItem = myBackButton
            
            userDetailsController.cardViewModel = user.toCardViewModel()
            self.navigationController?.pushViewController(userDetailsController, animated: true)
            
            
        })
    }
    
    var hasFavorited = Bool()
    // pass cell as a parameter to deal with it turning red
    
    func handleLike(cell: UITableViewCell) {
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        cell.accessoryView?.tintColor = .red
    }
    
    func handleDislike(cell: UITableViewCell) {
        saveSwipeToFireStore(didLike: 0)
        cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    //Searchbar stuff
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension SchoolCrushController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
