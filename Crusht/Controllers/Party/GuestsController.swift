////
////  GuestsController.swift
////  Crusht
////
////  Created by William Kelly on 2/20/20.
////  Copyright © 2020 William Kelly. All rights reserved.
////
//
//import UIKit
//import Firebase
//import SDWebImage
//import FirebaseStorage
//import FirebaseFirestore
//import FirebaseAuth
//
//class GuestsController: UITableViewController, UISearchBarDelegate, UITabBarControllerDelegate {
//
//    
//    var fetchedAllUsers = false
//    var fetchingMoreUsers = false
//    var lastFetchedDocument: QueryDocumentSnapshot? = nil
//    
//    var lastFetchedNumber: Any?
//  
//    let messageController = MessageController()
//    var schoolDelegate: SchoolDelegate?
//    
//    private var crushScore: CrushScore?
//    var hasFavorited = Bool()
//    var locationSwipes = [String: Int]()
//    var blocks = [String: Int]()
//    var sawMessage = Bool()
//    var isRightSex = Bool()
//    var crushScoreID = String()
//    var matchUID = String()
//
//    var phoneNumbers = [String]()
//    
//    let cellId = "cellId"
//    let loadingCellId = "loadingCellId"
//    var party: Party?
//    var user: User?
//    var guestArray = [Guest]()
//    var users = [Guest]()
//    var guestsUserDictionary = [String: User]()
//    var swipes = [String: Int]()
//    
//    // MARK: - Life Cycle Methods
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//         navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationController?.navigationBar.isHidden = false
//        navigationItem.title = "\(party?.partyName ?? "") Guests"
//        if UIApplication.shared.applicationIconBadgeNumber == 1 {
//            self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = "!"
//            self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = .red
//        }
//        fetchCurrentUser()
//    }
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tabBarController?.delegate = self
//        
//        tableView.register(GuestListCell.self, forCellReuseIdentifier: cellId)
//        tableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCellId)
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-32"), style: .plain, target: self, action: #selector(handleInfo))
//        
//        listenForMessages()
//        
//        // Setup the Search Controller
//        //view.addSubview(searchController.searchBar)
////        searchController.searchResultsUpdater = self
////        searchController.obscuresBackgroundDuringPresentation = false
////        searchController.searchBar.placeholder = "Search School"
//       // navigationItem.searchController = self.searchController
//        definesPresentationContext = true
//           
//        // Setup the Scope Bar
////        self.searchController.searchBar.delegate = self
////        self.navigationItem.hidesSearchBarWhenScrolling = false
//        messageBadge.isHidden = true
//        
//        //refresh controll
//        self.tableView.refreshControl = UIRefreshControl()
//        refreshControl?.addTarget(self, action: #selector(reloadGuests), for: .valueChanged)
//        refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
//        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)]
//        let attributedTitle = NSAttributedString(string: "Reloading", attributes: attributes)
//        refreshControl?.attributedTitle = attributedTitle
//        
//
//        // Setup the search footer
//        navigationController?.navigationBar.isTranslucent = false
//        //searchController.searchBar.barStyle = .black
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        
//    
//    }
//    
//    // MARK: - Logic
//    
//    @objc fileprivate func handleInfo() {
//        let partyController = PartyInfoController()
//              partyController.party = party
//              partyController.user = self.user
//              //userDetailsController.delegate = self
//              self.navigationController?.pushViewController(partyController, animated: true)
//    }
//    
//    @objc fileprivate func reloadGuests () {
//
//        fetchCurrentUser()
//        DispatchQueue.main.async {
//             self.tableView.refreshControl?.endRefreshing()
//          }
//    }
//    
//    fileprivate func addCrushScore() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//        let cardUID = crushScoreID
//
//        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
//            if err != nil {
//                return
//            }
//            if snapshot?.exists == true {
//                guard let dictionary = snapshot?.data() else {return}
//                self.crushScore = CrushScore(dictionary: dictionary)
//                let docData: [String: Any] = ["CrushScore": (self.crushScore?.crushScore ?? 0 ) + 1]
//                Firestore.firestore().collection("score").document(uid).setData(docData)
//            }
//            else {
//                let docData: [String: Any] = ["CrushScore": 1]
//                Firestore.firestore().collection("score").document(uid).setData(docData)
//            }
//        }
//        
//        Firestore.firestore().collection("score").document(cardUID).getDocument { (snapshot, err) in
//            if err != nil {
//                return
//            }
//            if snapshot?.exists == true {
//                guard let dictionary = snapshot?.data() else {return}
//                self.crushScore = CrushScore(dictionary: dictionary)
//                let cardDocData: [String: Any] = ["CrushScore": (self.crushScore?.crushScore ?? 0 ) + 2]
//                Firestore.firestore().collection("score").document(cardUID).setData(cardDocData)
//            }
//            else {
//                let cardDocData: [String: Any] = ["CrushScore": 1]
//                Firestore.firestore().collection("score").document(cardUID).setData(cardDocData)
//            }
//        }
//        
//    }
//    
//    @objc func handleMessages() {
//        let messageController = MessageController()
//        messageBadge.removeFromSuperview()
//        sawMessage = true
//        messageController.user = user
//        let navController = UINavigationController(rootViewController: messageController)
//        present(navController, animated: true)
//        //navigationController?.pushViewController(messageController, animated: true)
//        
//    }
//    
//    fileprivate func listenForMessages() {
//        guard let toId = Auth.auth().currentUser?.uid else {return}
//        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId)
//            .addSnapshotListener { querySnapshot, error in
//                guard let snapshot = querySnapshot else {
//                    return
//                }
//                snapshot.documentChanges.forEach { diff in
//                    if (diff.type == .added) {
//                    }
//                    if (diff.type == .modified) {
//                        self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = "!"
//                        self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = .red
//                        UIApplication.shared.applicationIconBadgeNumber = 1
//                    }
//                    if (diff.type == .removed) {
//                    }
//                }
//        }
//    }
//    
//    fileprivate func fetchCurrentUser() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
//            if err != nil {
//                let loginController = LoginViewController()
//                self.present(loginController, animated: true)
//                return
//            }
//            guard let dictionary = snapshot?.data() else {return}
//            let user = User(dictionary: dictionary)
//            
//            
//            if self.user == nil || !self.user!.hasSamePreferences(user: user) || self.guestArray.isEmpty {
//                self.user = user
//                self.fetchedAllUsers = false
//                self.lastFetchedDocument = nil
//                self.guestArray.removeAll()
//                self.tableView.reloadData()
//                //self.fetchSwipes()
//               // self.fetchSchoolUsers()
//                self.fetchBlocks()
//            }
//        }
//      
//    }
//    
//    fileprivate func fetchBlocks() {
//        print("lololo")
//        Firestore.firestore().collection("blocks").document(user?.uid ?? "").getDocument { (snapshot, err) in
//                 if err != nil {
//                    print(err, "fuckmeman")
//                     return
//                 }
//            if snapshot!.exists {
//                 guard let data = snapshot?.data() as? [String: Int] else {return}
//                 self.blocks = data
//                self.newfetchGuests()
//            }
//            //print("kikiki")
//                self.newfetchGuests()
//            }
//          
//    }
//    
//    //JUST MAKE GUESTS JUST LIKE USERS
//        //STORE UID PHOTO ETC
//    
//    fileprivate func newfetchGuests() {
//        Firestore.firestore().collection("parties").document(party?.partyUID ?? "").collection("guests").getDocuments { (snapshot, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            snapshot?.documents.forEach({ (docSnapshot) in
//                let guestDictionary = docSnapshot.data()
//                let guest = Guest(dictionary: guestDictionary)
//                
//                self.guestArray.append(guest)
//            })
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//            })
//        }
//      }
//    
////    fileprivate func fetchGuestPartTwo() {
////        guard !fetchedAllUsers, !fetchingMoreUsers else { return }
////        fetchingMoreUsers = true
////        tableView.reloadSections(IndexSet(integer: 1), with: .none)
////        var query: Query
////         if let lastFetchedDocument = lastFetchedDocument {
////             query = Firestore.firestore().collection("users").whereField("PhoneNumber", in: self.phoneNumbers).order(by: "Full Name").start(afterDocument: lastFetchedDocument).limit(to: 10)
////         } else {
////             query = Firestore.firestore().collection("users").whereField("PhoneNumber", in: self.phoneNumbers).order(by: "Full Name").limit(to: 10)
////         }
////        query.getDocuments { (snapshot, err) in
////            if let err = err {
////                print(err)
////                return
////            }
////            guard err == nil, let snapshot = snapshot else { return }
////
////                  if snapshot.documents.count == 0 {
////                      self.fetchedAllUsers = true
////                      self.fetchingMoreUsers = false
////                      self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
////                      return
////                  }
////           self.lastFetchedNumber = snapshot.documents.last
////                       snapshot.documents.forEach({ (documentSnapshot) in
////                           let userDictionary = documentSnapshot.data()
////                           let crush = User(dictionary: userDictionary)
////                           print(crush.name ?? "puck")
////                           let isNotCurrentUser = crush.uid != Auth.auth().currentUser?.uid
////                           let hasBlocked = self.blocks[crush.uid ?? ""] == nil
////
////                           let sexPref = self.user?.sexPref
////                           if sexPref == "Female" {
////                               self.isRightSex = crush.gender == "Female" || crush.gender == "Other"
////                           }
////                           else if sexPref == "Male" {
////                               self.isRightSex = crush.gender == "Male" || crush.gender == "Other"
////                           }
////                           else {
////                               self.isRightSex = crush.school == self.user?.school
////                           }
////
////                           if hasBlocked && isNotCurrentUser {
////                               self.guestArray.append(crush)
////                           }
////                       })
////                       DispatchQueue.main.async(execute: {
////                           self.fetchingMoreUsers = false
////                           self.tableView.reloadData()
////                       })
////                       self.fetchSwipes()
////                       }
////                   }
//    
//    
////    fileprivate func fetchGuests() {
////        print("hi hi")
////        guard !fetchedAllUsers, !fetchingMoreUsers else { return }
////        fetchingMoreUsers = true
////        tableView.reloadSections(IndexSet(integer: 1), with: .none)
////
////        let partyUID = self.party?.partyUID ?? ""
////        navigationItem.title = "\(party?.partyName ?? "") Guests"
////
////        Firestore.firestore().collection("parties").document(partyUID).getDocument { (snap, err) in
////            if let err = err {
////                print(err, "fook")
////            }
////            guard let partyDict = snap?.data() else {return}
////            let party = Party(dictionary: partyDict)
////
////            self.phoneNumbers = party.guestPhoneNumbers as! [String]
////            print(self.phoneNumbers)
////
////
////        var query: Query
////            if let lastFetchedNumber = self.lastFetchedNumber {
////                query = Firestore.firestore().collection("users").whereField("PhoneNumber", in: self.phoneNumbers).order(by: "Full Name").start(after: [lastFetchedNumber]).limit(to: 9)
////
////        } else {
////            query = Firestore.firestore().collection("users").whereField("PhoneNumber", in: self.phoneNumbers).order(by: "Full Name").limit(to: 9)
////        }
////
////        // Change logic where gender variable is just the where field firebase thing
////        query.getDocuments { (snapshot, err) in
////            guard err == nil, let snapshot = snapshot else { return }
////
////            if snapshot.documents.count == 0 {
////                self.fetchedAllUsers = true
////                self.fetchingMoreUsers = false
////                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
////                return
////            }
////
////            self.lastFetchedNumber = snapshot.documents.last
////            snapshot.documents.forEach({ (documentSnapshot) in
////                let userDictionary = documentSnapshot.data()
////                let crush = User(dictionary: userDictionary)
////                print(crush.name ?? "puck")
////                let isNotCurrentUser = crush.uid != Auth.auth().currentUser?.uid
////                let hasBlocked = self.blocks[crush.uid ?? ""] == nil
////
////                let sexPref = self.user?.sexPref
////                if sexPref == "Female" {
////                    self.isRightSex = crush.gender == "Female" || crush.gender == "Other"
////                }
////                else if sexPref == "Male" {
////                    self.isRightSex = crush.gender == "Male" || crush.gender == "Other"
////                }
////                else {
////                    self.isRightSex = crush.school == self.user?.school
////                }
////
////                if hasBlocked && isNotCurrentUser && self.isRightSex {
////                    self.guestArray.append(crush)
////                }
////            })
////            DispatchQueue.main.async(execute: {
////                self.fetchingMoreUsers = false
////                self.tableView.reloadData()
////            })
////            self.fetchSwipes()
////            }
////        }
////
////    }
//    
//    func hasTappedCrush(cell: UITableViewCell) {
//        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
//        let crush = isFiltering() ? users[indexPathTapped.row] : guestArray[indexPathTapped.row]
//        crushScoreID = crush.uid ?? ""
//        
//        let phoneString = crush.phoneNumber ?? ""
//        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
//        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
//        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
//        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
//        
//        matchUID = phoneNoDash
//        
//        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1) {
//            handleLike(cell: cell)
//        }
//        else {
//            handleDislike(cell: cell)
//        }
//    }
//    
//    func saveSwipeToFireStore(didLike: Int) {
//        
//        let phoneID = user?.phoneNumber ?? ""
//        
//        let cardUID = matchUID
//        
//        let documentData = [cardUID: didLike]
//        let otherDocData = [crushScoreID: didLike]
//        
//        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
//            if err != nil {
//                return
//            }
//            if snapshot?.exists == true {
//                Firestore.firestore().collection("phone-swipes").document(phoneID).updateData(documentData) { (err) in
//                    if err != nil {
//                        return
//                    }
//                    if didLike == 1 {
//                        self.checkIfMatchExists(cardUID: cardUID)
//                    }
//                }
//            } else {
//                Firestore.firestore().collection("phone-swipes").document(phoneID).setData(documentData) { (err) in
//                    if err != nil {
//                        return
//                    }
//                    if didLike == 1 {
//                        self.checkIfMatchExists(cardUID: cardUID)
//                    }
//                }
//            }
//            
//            Firestore.firestore().collection("swipes").document(self.user?.uid ?? "").getDocument { (snapshot, err) in
//                if err != nil {
//                    return
//                }
//                if snapshot?.exists == true {
//                    Firestore.firestore().collection("swipes").document(self.user?.uid ?? "").updateData(otherDocData) { (err) in
//                        if err != nil {
//                            return
//                        }
//                        if didLike == 1 {
//                           print("great")
//                        }
//                    }
//                } else {
//                        print("Success saved swipe SETDATA")
//                    }
//                self.fetchSwipes()
//            }
//        }
//    }
//    
//    fileprivate func checkIfMatchExists(cardUID: String) {
//        Firestore.firestore().collection("phone-swipes").document(cardUID).getDocument { (snapshot, err) in
//            if err != nil {
//                return
//            }
//            guard let data = snapshot?.data() else {return}
//            
//            let phoneNumber = self.user?.phoneNumber ?? ""
//            
//            let hasMatched = data[phoneNumber] as? Int == 1
//            if hasMatched {
//                self.getCardUID(phoneNumber: cardUID)
//            }
//        }
//    }
//    
//    fileprivate func getCardUID(phoneNumber: String) {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        
//        let phone = phoneNumber
//        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
//            
//            if err != nil {
//                return
//            }
//            snapshot?.documents.forEach({ (documentSnapshot) in
//                let userDictionary = documentSnapshot.data()
//                let user = User(dictionary: userDictionary)
//                
//                let cardUID = user.uid!
//                
//                Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, err) in
//                    if err != nil {
//                        return
//                    }
//                    let secondUserDictionary = snapshot?.data()
//                    let secondUser = User(dictionary: secondUserDictionary!)
//                    let otherDocData: [String: Any] = ["uid": uid, "Full Name": secondUser.name ?? "", "School": secondUser.school ?? "", "ImageUrl1": secondUser.imageUrl1!, "matchName": user.name ?? ""
//                    ]
//                    
//                    let docData: [String: Any] = ["uid": cardUID, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!, "matchName": secondUser.name ?? ""
//                    ]
//                    
//                    // This is for message controller
//                    Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: cardUID).getDocuments(completion: { (snapshot, err) in
//                        if err != nil {
//                            return
//                        }
//                        
//                        if (snapshot?.isEmpty)! {
//                            Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
//                            Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
//                            self.handleSend(cardUID: cardUID, cardName: user.name ?? "")
//                        }
//                    })
//                })
//            })
//        }
//    }
//    
//    fileprivate func fetchSwipes() {
//        let phoneID = user?.phoneNumber ?? ""
//        
//        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
//            if err != nil {
//                return
//            }
//            guard let data = snapshot?.data() as? [String: Int] else {return}
//            self.swipes = data
//            
//            self.fetchMoreSwipes()
//        }
//    }
//    
//    fileprivate func fetchMoreSwipes() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
//            if err != nil { return }
//            guard let data = snapshot?.data() as? [String: Int] else {return}
//            self.locationSwipes = data
//            DispatchQueue.main.async(execute: {
//                self.tableView.reloadData()
//            })
//        }
//    }
//    
//    @objc func handleSend(cardUID: String, cardName: String) {
//        let properties = ["text": "We matched! This is an automated message."]
//        sendAutoMessage(properties as [String : AnyObject], cardUID: cardUID, cardNAME: cardName)
//    }
//    
//    fileprivate func sendAutoMessage(_ properties: [String: AnyObject], cardUID: String, cardNAME: String) {
//        let toId = cardUID
//        let fromId = Auth.auth().currentUser!.uid
//        let toName = cardNAME
//        let timestamp = Int(Date().timeIntervalSince1970)
//        
//        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": user?.name as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
//        properties.forEach({values[$0] = $1})
//        
//        // Flip to id and from id to fix message controller query glitch
//        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
//        properties.forEach({otherValues[$0] = $1})
//        
//        // SOLUTION TO CURRENT ISSUE
//        // If statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
//        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
//            if err != nil { return }
//            if (snapshot?.isEmpty)! {
//                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
//                    if err != nil { return }
//                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
//                        if err != nil { return }
//                        snapshot?.documents.forEach({ (documentSnapshot) in
//                            let document = documentSnapshot
//                            if document.exists {
//                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
//                            } else{
//                                print("DOC DOESN't exist yet")
//                            }
//                        })
//                    })
//                }
//            } else {
//                snapshot?.documents.forEach({ (documentSnapshot) in
//                    let document = documentSnapshot
//                    if document.exists {
//                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
//                        // Message row update fix
//                        
//                        // Sort a not to update from id stuff
//                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
//                        
//                        // Flip it
//                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
//                            if err != nil { return }
//                            snapshot?.documents.forEach({ (documentSnapshot) in
//                                let document = documentSnapshot
//                                if document.exists {
//                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(otherValues)
//                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: otherValues)
//                                }
//                            })
//                        })
//                    }
//                })
//            }
//        })
//        self.sendAutoMessageTWO(properties, cardNAME: user?.name ?? "", fromId: toId, toId: fromId, toName: toName)
//    }
//    
//    fileprivate func sendAutoMessageTWO(_ properties: [String: AnyObject], cardNAME: String, fromId: String, toId: String, toName: String) {
//        let toId = toId
//        let fromId = fromId
//        let toName = toName
//        let timestamp = Int(Date().timeIntervalSince1970)
//        
//        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": user?.name as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
//        properties.forEach({values[$0] = $1})
//        
//        // Flip to id and from id to fix message controller query glitch
//        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": toName as AnyObject, "toName": user?.name as AnyObject, "timestamp": timestamp as AnyObject]
//        properties.forEach({otherValues[$0] = $1})
//        
//        // SOLUTION TO CURRENT ISSUE
//        // If statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
//        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
//            if err != nil { return }
//            if (snapshot?.isEmpty)! {
//                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
//                    if err != nil { return }
//                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
//                        if err != nil {
//                            return
//                        }
//                        
//                        snapshot?.documents.forEach({ (documentSnapshot) in
//                            let document = documentSnapshot
//                            if document.exists {
//                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
//                            } else{
//                                print("DOC DOESN't exist yet")
//                            }
//                        })
//                    })
//                }
//            } else {
//                snapshot?.documents.forEach({ (documentSnapshot) in
//                    let document = documentSnapshot
//                    if document.exists {
//                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
//                        // Message row update fix
//                        
//                        // Sort a not to update from id stuff
//                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
//                        
//                        // Flip it
//                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
//                            if err != nil { return }
//                            
//                            snapshot?.documents.forEach({ (documentSnapshot) in
//                                let document = documentSnapshot
//                                if document.exists {
//                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(otherValues)
//                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: otherValues)
//                                }
//                            })
//                        })
//                    }
//                })
//            }
//        })
//        self.presentMatchView(cardUID: fromId)
//    }
//    
//    func presentMatchView(cardUID: String) {
//        let matchView = MatchView()
//        matchView.cardUID = cardUID
//        matchView.currentUser = self.user
//        self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
//        self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
//        UIApplication.shared.applicationIconBadgeNumber = 1
//        MessageController.sharedInstance?.didHaveNewMessage = true
//
//        self.tabBarController?.view.addSubview(matchView)
//        matchView.bringSubviewToFront(view)
//        matchView.fillSuperview()
//    }
//    
//    func handleLike(cell: UITableViewCell) {
//        saveSwipeToFireStore(didLike: 1)
//        addCrushScore()
//        cell.accessoryView?.tintColor = .red
//    }
//    
//    func handleDislike(cell: UITableViewCell) {
//        saveSwipeToFireStore(didLike: 0)
//        cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
//    }
//    
//    @objc fileprivate func handleBack() {
//        dismiss(animated: true)
//    }
//    
//    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 65.0
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            if isFiltering() {
//                return users.count
//            }
//            if guestArray.isEmpty {
//                return 1
//            }
//            return guestArray.count
//            
//        } else if section == 1 && fetchingMoreUsers {
//            return 1
//        }
//        
//        return 0
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.backgroundColor = UIColor.clear
//        if guestArray.count > 0 && indexPath.section == 0 && indexPath.row >= guestArray.count - 3 && !isFiltering() {
//            newfetchGuests()
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GuestListCell
//            cell.link = self
//            if !guestArray.isEmpty {
//                let guest = isFiltering() ? users[indexPath.row] : guestArray[indexPath.row]
//                let hasLiked = swipes[guest.phoneNumber ?? ""] == 1
//                let swipeLike = locationSwipes[guest.uid ?? ""] == 1
//                hasFavorited = hasLiked || swipeLike
//                cell.setup(crush: guest, hasFavorited: hasFavorited)
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    if self.guestArray.isEmpty {
//                        cell.profileImageView.image = nil
//                        cell.textLabel?.text = "No Guests"
//                        cell.accessoryView?.isHidden = true
//                    }
//                }
//            }
//            return cell
//        } else { // Set up loading cell
//            let loadingCell = tableView.dequeueReusableCell(withIdentifier: loadingCellId, for: indexPath) as! LoadingCell
//            loadingCell.spinner.startAnimating()
//            return loadingCell
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard guestArray.count > 0 else { return }
//        let crush = isFiltering() ? users[indexPath.row] : guestArray[indexPath.row]
//        guard let profUID = crush.uid else { return }
//        
//        Firestore.firestore().collection("users").document(profUID).getDocument(completion: { (snapshot, err) in
//            guard let dictionary = snapshot?.data() as [String: AnyObject]? else {return}
//            
//            var user = User(dictionary: dictionary)
//            user.uid = profUID
//            let userDetailsController = UserDetailsController()
//            
//            let myBackButton = UIBarButtonItem()
//            myBackButton.title = " "
//            self.navigationItem.backBarButtonItem = myBackButton
//            
//            userDetailsController.cardViewModel = user.toCardViewModel()
//            //userDetailsController.delegate = self
//            self.navigationController?.pushViewController(userDetailsController, animated: true)
//        })
//    }
//    
//    // MARK: - UISearchBar
//    
//    let searchController = UISearchController(searchResultsController: nil)
//    
//    func isFiltering() -> Bool {
//        return searchController.isActive && !searchBarIsEmpty()
//    }
//    
//    func searchBarIsEmpty() -> Bool {
//        return searchController.searchBar.text?.isEmpty ?? true
//    }
//    
//    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        users = guestArray.filter({( user : Guest) -> Bool in
//            return user.firstName!.lowercased().contains(searchText.lowercased())
//        })
//        
//        tableView.reloadData()
//    }
//    
//
//    // MARK: - SettingsControllerDelegate
//    
//    func didSaveSettings() {
//        fetchCurrentUser()
//    }
//    
//    // MARK: - LoginControllerDelegate
//
//    func didFinishLoggingIn() {
//        fetchCurrentUser()
//    }
//    
//    // MARK: - UITabBarControllerDelegate
//    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let tabBarIndex = tabBarController.selectedIndex
//        if tabBarIndex == 4 {
//            self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = nil
//            self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = .clear
//        }
//    }
//    
//    // MARK: - User Interface
//    
//    let messageBadge: UILabel = {
//        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
//        label.layer.borderColor = UIColor.clear.cgColor
//        label.layer.borderWidth = 2
//        label.layer.cornerRadius = label.bounds.size.height / 2
//        label.textAlignment = .center
//        label.layer.masksToBounds = true
//        label.font = UIFont.systemFont(ofSize: 10)
//        label.textColor = .white
//        label.backgroundColor = .red
//        label.text = "!"
//        return label
//    }()
//}
//
//extension GuestsController: UISearchResultsUpdating {
//    // MARK: - UISearchResultsUpdating Delegate
//    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}
