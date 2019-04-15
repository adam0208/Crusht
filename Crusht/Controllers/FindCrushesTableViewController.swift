//
//  FindCrushesTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import JGProgressHUD


class FindCrushesTableViewController: UITableViewController, UISearchBarDelegate {
    

    let cellId = "cellId123123"
    
    var users = [User]()
    
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
            print(self.user?.phoneNumber ?? "Fuck you")
            self.fetchSwipes()
            self.tableView.reloadData()
            
        }
    }
    

    // you should use Custom Delegation properly instead
    func someMethodIWantToCall(cell: UITableViewCell) {

        // we're going to figure out which name we're clicking on
        
        print("you are liking something")
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let contact = twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row]
      
        
//        let hasFavorited = contact.hasFavorited
//        twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row].hasFavorited = !hasFavorited
        
        let phoneString = contact.contact.phoneNumbers.first?.value.stringValue ?? ""
        
        phoneID = phoneString
        
//        cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1) {
            
            handleLike(cell: cell)
        }
        else {
            print("fuck me")
            handleDislike(cell: cell)
        }
    }

    var phoneID: String?

    var twoDimensionalArray = [ExpandableNames]()
    lazy var filteredContanct = [ExpandableNames]()

    fileprivate func fetchContacts() {
        print("Attempting to fetch contacts today..")

        let store = CNContactStore()

        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }

            if granted {
                print("Access granted")

                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

                request.sortOrder = CNContactSortOrder.givenName

                do {

                    var favoritableContacts = [FavoritableContact]()

                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in

                        print(contact.givenName)
                        print(contact.familyName)
                        print(contact.phoneNumbers.first?.value.stringValue ?? "")

                        favoritableContacts.append(FavoritableContact(contact: contact, hasFavorited: false))
                        
                        
//
//                        self.filteredContanct = ["\(contact.givenName) \(contact.familyName)"]
                        //                        favoritableContacts.append(FavoritableContact(name: contact.givenName + " " + contact.familyName, hasFavorited: false))
                    })

                    let names = ExpandableNames(isExpanded: true, names: favoritableContacts)
                    self.twoDimensionalArray = [names]
                    
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        
                    })
                    

                } catch let err {
                    print("Failed to enumerate contacts:", err)
                }

            } else {
                print("Access denied..")
            }
        }
    }
    
    var phoneFinal = String()
    var showIndexPaths = false
    
    func saveSwipeToFireStore(didLike: Int) {
 
        let phoneNumber = user?.phoneNumber ?? ""
        
        //let crush = schoolArray[IndexPath.row]
        let phoneString = phoneID ?? ""
        
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        
        print(phoneNoDash)
        
        if phoneNoDash.count < 11 {
            phoneFinal = "+1\(phoneNoDash)"
        }
        else {
            phoneFinal = phoneNoDash
        }
        
        print(phoneFinal)

        //LOT OF TRIMMING AND STRIPPING
        
        let cardUID = phoneFinal
        
        let twilioPhoneData: [String: Any] = ["phoneToInvite": phoneNoDash]
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phoneFinal).getDocuments { (snapshot, err) in
            
            if let err = err {
                print("Major fuck up", err)
            }
           
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("twilio-invites").addDocument(data: twilioPhoneData)
                
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
                    if let err = err {
                        print("Failed to fetch swipe doc", err)
                        return
                    }
                    if snapshot?.exists == true {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).updateData(documentData) { (err) in
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
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).setData(documentData) { (err) in
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
            
            else {
        
        Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe doc", err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).updateData(documentData) { (err) in
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
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).setData(documentData) { (err) in
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
            
            //guard let uid = Auth.auth().currentUser?.uid else {return}
            let phoneNumber = self.user?.phoneNumber ?? ""
            
            let hasMatched = data[phoneNumber] as? Int == 1
            if hasMatched {
                print("we have a match!")
                self.getCardUID(phoneNumber: cardUID)
            }
        }
    }
   
    //var crushScoreIDFromPhoneNumber = String()
   
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
    
    var crushScoreID = String()
    
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
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
       let phoneNumber = user?.phoneNumber ?? ""
        
        Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            print("phone-Swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            // self.fetchUsersFromFirestore()
            //self.fetchUsersOnLoad()
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                
            })
        }
     
    }
    
    func handleLike(cell: UITableViewCell) {
        
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        
        cell.accessoryView?.tintColor = .red
        
    }
    
    func handleDislike(cell: UITableViewCell) {
        
        saveSwipeToFireStore(didLike: 0)
        
        cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
        
    }
    
    fileprivate var crushScore: CrushScore?
    
    fileprivate func addCrushScore() {
        
        print("starting journey master cheif")
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //let cardUID = crushScoreID
        
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
        
//        Firestore.firestore().collection("score").document(cardUID).getDocument { (snapshot, err) in
//            if let err = err {
//                print(err)
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
        
    }
    
    @objc func handleShowIndexPath() {
        
        print("Attemping reload animation of indexPaths...")
        
        // build all the indexPaths we want to reload
        var indexPathsToReload = [IndexPath]()
        
        for section in twoDimensionalArray.indices {
            for row in twoDimensionalArray[section].names.indices {
                print(section, row)
                let indexPath = IndexPath(row: row, section: section)
                indexPathsToReload.append(indexPath)
            }
        }
        
        //        for index in twoDimensionalArray[0].indices {
        //            let indexPath = IndexPath(row: index, section: 0)
        //            indexPathsToReload.append(indexPath)
        //        }
        
        showIndexPaths = !showIndexPaths
        
        let animationStyle = showIndexPaths ? UITableView.RowAnimation.right : .left
        
        tableView.reloadRows(at: indexPathsToReload, with: animationStyle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        navigationController?.isNavigationBarHidden = false
        
        // Setup the Scope Bar
        //self.searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        fetchContacts()
        fetchCurrentUser()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show IndexPath", style: .plain, target: self, action: #selector(handleShowIndexPath))
        
        navigationItem.title = "Contacts"
//        navigationItem.leftItemsSupplementBackButton = true
//        navigationItem.leftBarButtonItem?.title = "👈"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .plain, target: self, action: #selector(handleBack))
        //UINavigationItem.setLeftBarButton(back)
        tableView.register(ContactsCell.self, forCellReuseIdentifier: cellId)
        //tableView.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
        tableView.reloadData()
    }
    
    let hud = JGProgressHUD(style: .dark)

    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
//    fileprivate var expanded = false

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContanct.count
        }
        
        return twoDimensionalArray[section].names.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let cell = ContactsCell(style: .subtitle, reuseIdentifier: cellId)
        
        cell.link = self
        
        let favoritableContact = twoDimensionalArray[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
        
        
        let phoneString = favoritableContact.contact.phoneNumbers.first?.value.stringValue ?? ""
        
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        var phoneCellFinal = String()
        
        if phoneNoDash.count < 11 {
            phoneCellFinal = "+1\(phoneNoDash)"
        }
        else {
            phoneCellFinal = phoneNoDash
        }
        
        let hasLiked = swipes[phoneCellFinal] as? Int == 1
        
        
        
        if hasLiked{
            cell.accessoryView?.tintColor = .red
            
        }
        else {
            cell.accessoryView?.tintColor = #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
        }
        
        //cell.accessoryView?.tintColor = favoritableContact.hasFavorited ? UIColor.red : #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
        
        if isFiltering() {
            let favoritableContact = filteredContanct[indexPath.section].names[indexPath.row]
            cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            
            cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
          
        } else {
            let favoritableContact = twoDimensionalArray[indexPath.section].names[indexPath.row]
            cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            
            cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
        }
        
       
        return cell
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
        
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        //let favoritableContact = twoDimensionalArray[IndexPath.section].names[IndexPath.row]
        
        filteredContanct = twoDimensionalArray.filter({( user : ExpandableNames ) -> Bool in
            //            var favoritableContacts = [FavoritableContact]()
            //            let names = ExpandableNames(isExpanded: true, names: favoritableContacts)
            //            self.twoDimensionalArray = [names]
             user.names.contains(where: { (contact) -> Bool in
                return contact.contact.givenName.lowercased().contains(searchText.lowercased())
                
            })
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            
        })
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
 }


extension FindCrushesTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
    
    

