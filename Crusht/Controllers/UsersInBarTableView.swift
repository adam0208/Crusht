//
//  UsersInBarTableView.swift
//  Crusht
//
//  Created by William Kelly on 5/4/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

import Firebase
import CoreLocation
import GeoFire

//This controller shows users in bar which they have joined

class UsersInBarTableView: UITableViewController, UISearchBarDelegate, SettingsControllerDelegate {
    var fetchedAllUsers = false
    var fetchingMoreUsers = false
    var lastFetchedDocument: QueryDocumentSnapshot? = nil
    
    var user: User?
    var barsArray = [User]()
    var users = [User]()
    var swipes = [String: Int]()
    var locationSwipes = [String: Int]()
    
    var isRightSex = Bool()
    var barName = String()
    var schoolUserDictionary = [String: User]()
    var hasFavorited = Bool()
    
    var crushScoreID = String()
    var matchUID = String()
    private var crushScore: CrushScore?
    
    let messageController = MessageController()
    
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    
    // MARK: - Life Cycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        fetchCurrentUser()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserBarCell.self, forCellReuseIdentifier: cellId)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCellId)
       
        listenForMessages()
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search School"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        // Setup the search footer
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        searchController.searchBar.barStyle = .black
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    // MARK: - Logic
    
    private func addCrushScore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let cardUID = crushScoreID
        
        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            if snapshot?.exists == true {
                guard let dictionary = snapshot?.data() else { return }
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
                guard let dictionary = snapshot?.data() else { return }
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
    
    private func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
                    self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
            }
        }
    }
    
    @objc private func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func handleMatchByLocationBttnTapped() {
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
    
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            let user = User(dictionary: dictionary)
            if user.name == "" {
                let namecontroller = EnterNameController()
                namecontroller.phone = self.user?.phoneNumber ?? ""
                self.present(namecontroller, animated: true)
            }
            
            if self.user == nil || !self.user!.hasSamePreferences(user: user) || self.barsArray.isEmpty {
                self.user = user
                self.fetchedAllUsers = false
                self.lastFetchedDocument = nil
                self.barsArray.removeAll()
                self.tableView.reloadData()
                //self.fetchSwipes()
                self.fetchMoreUsersInBar()
            }
        }
    }
    
    private func fetchMoreUsersInBar() {
        guard !fetchedAllUsers, !fetchingMoreUsers else { return }
        fetchingMoreUsers = true
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        navigationItem.title = "\(barName) (Joined)"
        
        var query: Query
        if let lastFetchedDocument = lastFetchedDocument {
            query = Firestore.firestore().collection("users").whereField("CurrentVenue", isEqualTo: barName).order(by: "Full Name").start(afterDocument: lastFetchedDocument).limit(to: 15)
        } else {
            query = Firestore.firestore().collection("users").whereField("CurrentVenue", isEqualTo: barName).order(by: "Full Name").limit(to: 15)
        }
        
        // Chagne logic where gender variable is just the where field firebase thing
        
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
                
                let maxAge = crush.age ?? 18 < ((self.user?.age)! + 5)
                let minAge = crush.age ?? 18 > ((self.user?.age)! - 5)
                
                if isNotCurrentUser && minAge && maxAge && self.isRightSex {
                    self.barsArray.append(crush)
                }
            })
            
            DispatchQueue.main.async(execute: {
                self.fetchingMoreUsers = false
                self.tableView.reloadData()
            })
            self.fetchSwipes()
        }
    }
    
    func hasTappedCrush(cell: UITableViewCell) {
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let crush = isFiltering() ? users[indexPathTapped.row] : barsArray[indexPathTapped.row]
        crushScoreID = crush.uid ?? ""
        
        let phoneString = crush.phoneNumber ?? ""
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        
        matchUID = phoneNoDash
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) {
            handleLike(cell: cell)
        }
        else {
            handleDislike(cell: cell)
        }
    }
        
    private func saveSwipeToFireStore(didLike: Int) {
        let phoneID = user?.phoneNumber ?? ""
        let cardUID = matchUID
        let documentData = [cardUID: didLike]
        let otherDocData = [crushScoreID: didLike]
        
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if err != nil { return }
            if snapshot?.exists == true {
                Firestore.firestore().collection("phone-swipes").document(phoneID).updateData(documentData) { (err) in
                    if err != nil { return }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("phone-swipes").document(phoneID).setData(documentData) { (err) in
                    if err != nil { return }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
            
            Firestore.firestore().collection("swipes").document(self.user?.uid ?? "").getDocument { (snapshot, err) in
                if err != nil, let exists = snapshot?.exists, exists { return }
                Firestore.firestore().collection("swipes").document(self.user?.uid ?? "").updateData(otherDocData) { (err) in
                    if err != nil { return }
                }
                self.fetchSwipes()
            }
        }
    }
        
    private func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("phone-swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch doc for card user", err)
                return
            }
            guard let data = snapshot?.data() else {return}
            
            let phoneNumber = self.user?.phoneNumber ?? ""
            let hasMatched = data[phoneNumber] as? Int == 1
            if hasMatched {
                self.getCardUID(phoneNumber: cardUID)
            }
        }
    }
    
    private func getCardUID(phoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let phone = phoneNumber
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
            if err != nil { return }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let cardUID = user.uid!
                
                Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, err) in
                    if err != nil { return }
                    let secondUserDictionary = snapshot?.data()
                    let secondUser = User(dictionary: secondUserDictionary!)
                    let otherDocData: [String: Any] = ["uid": uid, "Full Name": secondUser.name ?? "", "School": secondUser.school ?? "", "ImageUrl1": secondUser.imageUrl1!, "matchName": user.name ?? ""]
                    
                    let docData: [String: Any] = ["uid": cardUID, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!, "matchName": secondUser.name ?? ""]
                    
                    // This is for message controller
                    Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: cardUID).getDocuments(completion: { (snapshot, err) in
                        if (snapshot?.isEmpty)! {
                            Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                            Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
                            self.handleSend(cardUID: cardUID, cardName: user.name ?? "")
                        }
                    })
                })
            })
        }
    }

    private func fetchSwipes() {
        let phoneID = user?.phoneNumber ?? ""
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            self.fetchMoreSwipes()
        }
    }
    
    
    private func fetchMoreSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
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
    
    @objc private func handleSend(cardUID: String, cardName: String) {
        let properties = ["text": "We matched! This is an automated message."]
        sendAutoMessage(properties as [String : AnyObject], cardUID: cardUID, cardNAME: cardName)
    }
    
    private func sendAutoMessage(_ properties: [String: AnyObject], cardUID: String, cardNAME: String) {
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
        // If statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("Error making individual convo", err)
                return
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if let err = err {
                        print("error sending message", err)
                        return
                    }
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if let err = err {
                            print("Error making individual convo", err)
                            return
                        }
                        
                        snapshot?.documents.forEach({ (documentSnapshot) in
                            
                            let document = documentSnapshot
                            if document.exists {
                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                                // Need to update the message collum for other user
                                // Just flip toID and fromID
                            } else {
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
        
        //flip to id and from id to fix message controller query glitch
        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({otherValues[$0] = $1})
        
        //SOLUTION TO CURRENT ISSUE
        //if statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("Error making individual convo", err)
                return
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if let err = err {
                        print("error sending message", err)
                        return
                    }
                    //Firestore.firestore().collection("messages").addDocument(data: otherValues)
                    
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if let err = err {
                            print("Error making individual convo", err)
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
                            if let err = err {
                                print("Error making individual convo", err)
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
    
    private func presentMatchView(cardUID: String) {
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
    
    private func handleLike(cell: UITableViewCell) {
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        cell.accessoryView?.tintColor = .red
    }
    
    private func handleDislike(cell: UITableViewCell) {
        saveSwipeToFireStore(didLike: 0)
        cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
    }
    
    @objc private func handleBack() {
        dismiss(animated: true)
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
            return isFiltering() ? users.count : barsArray.count
        } else if section == 1 && fetchingMoreUsers {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserBarCell
            cell.link = self
            if !barsArray.isEmpty {
                let crush = isFiltering() ? users[indexPath.row] : barsArray[indexPath.row]
                let hasLiked = swipes[crush.phoneNumber ?? ""] == 1
                let swipeLike = locationSwipes[crush.uid ?? ""] == 1
                hasFavorited = hasLiked || swipeLike
                cell.setup(crush: crush, hasFavorited: hasFavorited)
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            return cell
        } else { // Set up loading cell
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: loadingCellId, for: indexPath) as! LoadingCell
            loadingCell.spinner.startAnimating()
            return loadingCell
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if barsArray.count > 0 && indexPath.section == 0 && indexPath.row >= barsArray.count - 3 && !isFiltering() {
            fetchMoreUsersInBar()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard barsArray.count > 0 else { return }
        let crush = isFiltering() ? users[indexPath.row] : barsArray[indexPath.row]
        guard let profUID = crush.uid else { return }

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
    
    // MARK: - UISearchBar
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        users = barsArray.filter({( user : User) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - SettingsControllerDelegate

    func didSaveSettings() {
        fetchCurrentUser()
    }
}





// MARK: - UISearchResultsUpdating Delegate
extension UsersInBarTableView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
