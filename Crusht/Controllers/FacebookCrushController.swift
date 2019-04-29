//
//  FacebookCrushController.swift
//  Crusht
//
//  Created by William Kelly on 1/24/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import JGProgressHUD
import FacebookLogin
import FBSDKLoginKit


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

class FacebookCrushController: UITableViewController, UISearchBarDelegate {
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    let hud = JGProgressHUD(style: .dark)
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
            print(self.user?.phoneNumber ?? "Fuck you")
            if self.user?.fbid == nil {
                self.handleBack()
            }
           
            
            self.fetchFacebookUser()
        }
    }
    
    var fullName: String?
    var school: String?
    var age: Int?
    var photoUrl: String?
    var socialID: String?
    
    var isRightSex = Bool()
    
    fileprivate func fetchFacebookUser() {
        print("starting fb")
        let req = GraphRequest(graphPath: "me/friends", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
                print("no fb for you")
            case .success(let graphResponse):
                print("Success doing this fb shit")
            
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    //let photoData = pictureUrlFB!["data"] as? [String:Any]
                    //let photoUrl = photoData!["url"] as? String

                    let responseDictionaryFriends = graphResponse.dictionaryValue
                    let data: NSArray = responseDictionaryFriends!["data"] as! NSArray
                
                    
                    print("jajajajajjajajajajja", data)
                    
                    
                    for i in  0..<data.count {
                        let dict = data[i] as! NSDictionary
                        let temp = dict.value(forKey: "id") as! String
                        Firestore.firestore().collection("users").whereField("fbid", arrayContains: temp).getDocuments(completion: { (snapshot, err) in
                            if let err = err {
                                print("failed getting fb friends", err)
                            }
                            snapshot?.documents.forEach({ (documentSnapshot) in
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
                                    self.isRightSex = crush.age > 17
                                }
                                
                                if isNotCurrentUser && self.isRightSex {
                                
                                self.fbArray.append(crush)
                                
                                
                                }
                                //                let crushStuff = User(dictionary: userDictionary)
                                //                if let crushPartnerId = crushStuff.crushPartnerId() {
                                //                    self.schoolUserDictionary[crushPartnerId] = user
                                //                    self.users = Array(self.schoolUserDictionary.values)
                                //                }
                                
                                self.fbArray.sorted(by: { (crush1, crush2) -> Bool in
                                    return crush1.name > crush2.name
                                })
                                
                            })
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                                
                            })
                            
                        })
                    }
                    
                    
                }
            }
            
            
        })
    }
    //log in to fb to sinc?
   
    
//    fileprivate func getFBFriends() {
//
//    let params = ["fields": "id"]
//
//        let request = GraphRequest(graphPath: "me/friends", parameters: params, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
//        let connection = GraphRequestConnection()
//    connection.add(request, completionHandler: { (connection, result, error) in
//    if error != nil {
//    print("error")
//    } else {
//    if let userData = result as? [String:Any] {
//    let data: NSArray = userData["data"] as! NSArray
//    for i in  0..<data.count {
//    let dict = data[i] as! NSDictionary
//    let temp = dict.value(forKey: "id") as! String
//    // temp is an ID of a Facebook friend
//
//        }
//        }
//        }
//        })
//    }

    fileprivate var crushScore: CrushScore?
    
    fileprivate func addCrushScore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let cardUID = crushScoreID
        
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
    
    var facebookCell = FacebookCrushCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellId = "cellId"
        
        fetchCurrentUser()
//        navigationItem.leftItemsSupplementBackButton = true
//        navigationItem.leftBarButtonItem?.title = "👈"
         navigationController?.isNavigationBarHidden = false

//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .plain, target: self, action: #selector(handleBack))
        
        navigationItem.title = "Facebook Friends"
        
        tableView.register(FacebookCrushCell.self, forCellReuseIdentifier: cellId)
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search FB Friends"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        
        
        // Setup the Scope Bar
        //self.searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        users = fbArray.filter({( user : User) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
     var user: User?
    
    
    fileprivate var fbArray = [User]()
    
    fileprivate var users = [User]()
    
    
    var schoolUserDictionary = [String: User]()
    
//    fileprivate func fetchSchool() {
//        
//        print("Fetching School Stuff ahahahahahah")
//        
//        let school = user?.school ?? "I suck a lot"
//        
//        navigationItem.title = school
//        
//        print(school)
//        
//        let query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school)
//        
//        query.getDocuments { (snapshot, err) in
//            if let err = err {
//                print("failed to fetch user", err)
//                self.hud.textLabel.text = "Failed To Fetch user"
//                self.hud.show(in: self.view)
//                self.hud.dismiss(afterDelay: 2)
//                return
//            }
//            
//            snapshot?.documents.forEach({ (documentSnapshot) in
//                let userDictionary = documentSnapshot.data()
//                let crush = User(dictionary: userDictionary)
//                
//                self.schoolArray.append(crush)
//                
//                
//                print(self.schoolArray)
//                //                let crushStuff = User(dictionary: userDictionary)
//                //                if let crushPartnerId = crushStuff.crushPartnerId() {
//                //                    self.schoolUserDictionary[crushPartnerId] = user
//                //                    self.users = Array(self.schoolUserDictionary.values)
//                //                }
//                
//                self.schoolArray.sorted(by: { (crush1, crush2) -> Bool in
//                    return crush1.name > crush2.name
//                })
//                
//            })
//            DispatchQueue.main.async(execute: {
//                self.tableView.reloadData()
//                
//            })
//        }
//        
//    }
    
     func hasTappedFBCrush(cell: UITableViewCell) {
        
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        print("YOU Have selected something")
        
        let crush = fbArray[indexPathTapped.row]
        
        crushScoreID = crush.uid ?? ""
        
        let phoneString = crush.phoneNumber ?? ""
        
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        
        matchUID = phoneNoDash
        
        //tableView.reloadRows(at: [indexPathTapped], with: .fade)
        
        //cell.tintColor = .red
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) {
            
            handleLike(cell: cell)
        }
        else {
            handleDislike(cell: cell)
        }
        
    }
    
    var crushScoreID = String()
    
    var matchUID = String()
    
    func handleDislike(cell: UITableViewCell) {
        
        saveSwipeToFireStore(didLike: 0)
        
        cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
        
    }
    
    
    func saveSwipeToFireStore(didLike: Int) {
        
        let phoneID = user?.phoneNumber ?? ""
        
        let cardUID = matchUID
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe doc", err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("phone-swipes").document(phoneID).updateData(documentData) { (err) in
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
                Firestore.firestore().collection("phone-swipes").document(phoneID).setData(documentData) { (err) in
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
        print(cardUID)
        
        Firestore.firestore().collection("phone-swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch doc for card user", err)
                return
            }
            guard let data = snapshot?.data() else {return}
            print(data)
            
            let phoneNumber = self.user?.phoneNumber ?? ""
            
            let hasMatched = data[phoneNumber] as? Int == 1
            if hasMatched {
                print("we have a match!")
                self.getCardUID(phoneNumber: cardUID)
            }
        }
    }
    
    fileprivate func getCardUID(phoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let phone = phoneNumber
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
            
            if let err = err {
                print("Major fuck up", err)
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let cardUID = user.uid!
                
                let docData: [String: Any] = ["uid": cardUID, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!
                ]
                let otherDocData: [String: Any] = ["uid": uid, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!
                ]
                //this is for message controller
                Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: cardUID).getDocuments(completion: { (snapshot, err) in
                    if let err = err {
                        print(err)
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
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        let phoneID = user?.phoneNumber ?? ""
        
        Firestore.firestore().collection("phone-swipes").document(phoneID).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            print("Swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            
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
        
        
        print("about to send new message")
        //SOLUTION TO CURRENT ISSUE
        //if statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            print("HAHHAHAAHAHAAAHAAHAH")
            if let err = err {
                print("Error making individual convo", err)
                return
            }
            
            if (snapshot?.isEmpty)! {
                print("SENDING NEW MESSAGE")
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if let err = err {
                        print("error sending message", err)
                        return
                    }
                    //Firestore.firestore().collection("messages").addDocument(data: otherValues)
                    
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        print("TITITITITITITITIITITIT")
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
                            print("TITITITITITITITIITITIT")
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
        
        
        print("about to send new message")
        //SOLUTION TO CURRENT ISSUE
        //if statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            print("HAHHAHAAHAHAAAHAAHAH")
            if let err = err {
                print("Error making individual convo", err)
                return
            }
            
            if (snapshot?.isEmpty)! {
                print("SENDING NEW MESSAGE")
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if let err = err {
                        print("error sending message", err)
                        return
                    }
                    //Firestore.firestore().collection("messages").addDocument(data: otherValues)
                    
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        print("TITITITITITITITIITITIT")
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
                            print("TITITITITITITITIITITIT")
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
    
    
    func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
 
        self.navigationController?.view.addSubview(matchView)
        matchView.bringSubviewToFront(view)
        matchView.fillSuperview()
    }
    
    @objc fileprivate func handleMessageButtonTapped() {
        let profileController = ProfilePageViewController()
        present(profileController, animated: true)
        let messageController = MessageController()
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
    }
    
    // MARK: - Table view data source
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return users.count
        }
        return fbArray.count
    }
    
    fileprivate var hasFavorited = false
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cellL = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FacebookCrushCell
        
         cellL.fblink = self
        
        if isFiltering() {
            let crush = users[indexPath.row]
            cellL.textLabel?.text = crush.name
            if let profileImageUrl = crush.imageUrl1 {
                cellL.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        } else {
            let crush = fbArray[indexPath.row]
            cellL.textLabel?.text = crush.name
            if let profileImageUrl = crush.imageUrl1 {
                cellL.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        }
        
        let crush = fbArray[indexPath.row]
        
        let hasLiked = swipes[crush.phoneNumber ?? ""] as? Int == 1
        
        if hasLiked {
            cellL.accessoryView?.tintColor = .red
            hasFavorited = true
        }
        else{
            cellL.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
        }
        //cellL.starButton.tintColor = hasFavorited ? UIColor.red : #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
        
        return cellL
    }
    
    func handleLike(cell: UITableViewCell) {
        
        
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        
        cell.accessoryView?.tintColor = .red
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let crush = fbArray[indexPath.row]
        
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
            //userDetailsController.view.backgroundColor = .purple
            userDetailsController.cardViewModel = user.toCardViewModel()
           self.navigationController?.pushViewController(userDetailsController, animated: true)
            
        })
    }
    
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension FacebookCrushController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

