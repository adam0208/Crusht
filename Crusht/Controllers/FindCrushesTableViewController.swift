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
import CoreLocation
import GeoFire


class FindCrushesTableViewController: UITableViewController, UISearchBarDelegate, LoginControllerDelegate, SettingsControllerDelegate, UITabBarControllerDelegate {
    
    let schoolController = SchoolCrushController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        handleContacts()
        tableView.reloadData()
    }
    fileprivate func handleContacts() {
                let store = CNContactStore()
                switch CNContactStore.authorizationStatus(for: .contacts) {
        
                case .authorized:
                    print("Hey")
                case .denied:
                    showSettingsAlert()
                case .restricted, .notDetermined:
                    store.requestAccess(for: .contacts) { granted, error in
                        if granted {
                            self.fetchContacts()
                        } else {
                            DispatchQueue.main.async {
                                self.showSettingsAlert()
                            }
                        }
                    }
                }
        
            }
    
        private func showSettingsAlert() {
            let alert = UIAlertController(title: "Enable Contacts", message: "Crusht requires access to Contacts to proceed. We use your contacts to help you find your match. WE DON'T STORE YOUR CONTACTS IN OUR DATABASE. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
    
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                return
            })
            present(alert, animated: true)
        }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }

    let cellId = "cellId123123"
    
    var users = [User]()
    
     var user: User?
        
        fileprivate func fetchCurrentUser() {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                if let err = err {
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
                
                let timestamp = Int(Date().timeIntervalSince1970)
                
                if Int(truncating: self.user?.timeLastJoined ?? 5000) < timestamp - 64800 {
                        
                        var docData = [String: Any]()
                        guard let uid = Auth.auth().currentUser?.uid else { return}
                    if self.user?.imageUrl1 != "" && self.user?.imageUrl2 != "" && self.user?.imageUrl3 != "" {
                            docData = [
                                "uid": uid,
                                "Full Name": self.user?.name ?? "",
                                "ImageUrl1": self.user?.imageUrl1 ?? "",
                                "ImageUrl2": self.user?.imageUrl2 ?? "",
                                "ImageUrl3": self.user?.imageUrl3 ?? "",
                                "Age": calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                                "Birthday": self.user?.birthday ?? "",
                                "School": self.user?.school ?? "",
                                "Bio": self.user?.bio ?? "",
                                "minSeekingAge": self.user?.minSeekingAge ?? 18,
                                "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                                "maxDistance": self.user?.maxDistance ?? 3,
                                "email": self.user?.email ?? "",
                                "fbid": self.user?.fbid ?? "",
                                "PhoneNumber": self.user?.phoneNumber ?? "",
                                "deviceID": Messaging.messaging().fcmToken ?? "",
                                "Gender-Preference": self.user?.sexPref ?? "",
                                "User-Gender": self.user?.gender ?? "",
                                "CurrentVenue": "",
                                "TimeLastJoined": timestamp - 3600
                                
                            ]
                        } else if self.user?.imageUrl1 != "" && self.user?.imageUrl2 != "" && self.user?.imageUrl3 == "" {
                            docData = [
                                "uid": uid,
                                "Full Name": self.user?.name ?? "",
                                "ImageUrl1": self.user?.imageUrl1 ?? "",
                                "ImageUrl2": self.user?.imageUrl2 ?? "",
                                "Age": calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                                "Birthday": self.user?.birthday ?? "",
                                "School": self.user?.school ?? "",
                                "Bio": self.user?.bio ?? "",
                                "minSeekingAge": self.user?.minSeekingAge ?? 18,
                                "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                                "maxDistance": self.user?.maxDistance ?? 3,
                                "email": self.user?.email ?? "",
                                "fbid": self.user?.fbid ?? "",
                                "PhoneNumber": self.user?.phoneNumber ?? "",
                                "deviceID": Messaging.messaging().fcmToken ?? "",
                                "Gender-Preference": self.user?.sexPref ?? "",
                                "User-Gender": self.user?.gender ?? "",
                                "CurrentVenue": "",
                                "TimeLastJoined": timestamp - 3600
                                
                            ]
                        }
                    else if self.user?.imageUrl1 != "" && self.user?.imageUrl2 == "" && self.user?.imageUrl3 == "" {
                            docData = [
                                "uid": uid,
                                "Full Name": self.user?.name ?? "",
                                "ImageUrl1": self.user?.imageUrl1 ?? "",
                                "Age": calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                                "Birthday": self.user?.birthday ?? "",
                                "School": self.user?.school ?? "",
                                "Bio": self.user?.bio ?? "",
                                "minSeekingAge": self.user?.minSeekingAge ?? 18,
                                "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                                "maxDistance": self.user?.maxDistance ?? 3,
                                "email": self.user?.email ?? "",
                                "fbid": self.user?.fbid ?? "",
                                "PhoneNumber": self.user?.phoneNumber ?? "",
                                "deviceID": Messaging.messaging().fcmToken ?? "",
                                "Gender-Preference": self.user?.sexPref ?? "",
                                "User-Gender": self.user?.gender ?? "",
                                "CurrentVenue": "",
                                "TimeLastJoined": timestamp - 3600
                                
                            ]
                        }
                        Firestore.firestore().collection("users").document(uid).setData(docData) { (err)
                            in
                            //hud.dismiss()
                            if let err = err {
                                return
                            }
                          
                        }
            
                }
                
                self.fetchSwipes()
    }
    
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
        let age = calcAge.year
        return age!
    }
}

    // you should use Custom Delegation properly instead
    func someMethodIWantToCall(cell: UITableViewCell) {
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let contact = twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row]
      
        
//        let hasFavorited = contact.hasFavorited
//        twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row].hasFavorited = !hasFavorited
        
        let phoneString = contact.contact.phoneNumbers.first?.value.stringValue ?? ""
        
        phoneID = phoneString
        
//        cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) {
            
            handleLike(cell: cell)
        }
        else {
            handleDislike(cell: cell)
        }
    }

    var phoneID: String?

    var twoDimensionalArray = [ExpandableNames]()
    lazy var filteredContanct = [ExpandableNames]()

    fileprivate func fetchContacts() {

        let store = CNContactStore()

        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                return
            }

            if granted {

                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

                request.sortOrder = CNContactSortOrder.givenName

                do {

                    var favoritableContacts = [FavoritableContact]()

                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in


                        favoritableContacts.append(FavoritableContact(contact: contact, hasFavorited: false))
                        
                        
//
//                        self.filteredContanct = ["\(contact.givenName) \(contact.familyName)"]
                        //                        favoritableContacts.append(FavoritableContact(name: contact.givenName + " " + contact.familyName, hasFavorited: false))
                    })

                    let names = ExpandableNames(isExpanded: true, names: favoritableContacts)
                    self.twoDimensionalArray = [names]
                    
                    self.fetchCurrentUser()
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        
                    })
                    

                } catch let err {
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
        
        
        if phoneNoDash.count < 11 {
            phoneFinal = "+1\(phoneNoDash)"
        }
        else {
            phoneFinal = phoneNoDash
        }
        

        //LOT OF TRIMMING AND STRIPPING
        
        let cardUID = phoneFinal
        
        let twilioPhoneData: [String: Any] = ["phoneToInvite": phoneFinal]
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phoneFinal).getDocuments { (snapshot, err) in
            
            if let err = err {
                return
            }
           
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("twilio-invites").addDocument(data: twilioPhoneData)
                
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
                    if let err = err {
                        return
                    }
                    if snapshot?.exists == true {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).updateData(documentData) { (err) in
                            if let err = err {
                                return
                            }
                            if didLike == 1 {
                                self.checkIfMatchExists(cardUID: cardUID)
                            }
                        }
                    } else {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).setData(documentData) { (err) in
                            if let err = err {
                                return
                            }
                            if didLike == 1 {
                                self.checkIfMatchExists(cardUID: cardUID)
                            }
                        }
                    }
                }
                
            }
            
            else {
        
        Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).updateData(documentData) { (err) in
                    if let err = err {
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).setData(documentData) { (err) in
                    if let err = err {
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
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
            let phoneNumber = self.user?.phoneNumber ?? ""
            
            let hasMatched = data[phoneNumber] as? Int == 1
            if hasMatched {
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
    
    var crushScoreID = String()
    
    
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
        
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
       let phoneNumber = user?.phoneNumber ?? ""
        
        Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
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
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //let cardUID = crushScoreID
        
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
    
//    @objc func handleShowIndexPath() {
//
//        print("Attemping reload animation of indexPaths...")
//
//        // build all the indexPaths we want to reload
//        var indexPathsToReload = [IndexPath]()
//
//        for section in twoDimensionalArray.indices {
//            for row in twoDimensionalArray[section].names.indices {
//                print(section, row)
//                let indexPath = IndexPath(row: row, section: section)
//                indexPathsToReload.append(indexPath)
//            }
//        }
//
//        //        for index in twoDimensionalArray[0].indices {
//        //            let indexPath = IndexPath(row: index, section: 0)
//        //            indexPathsToReload.append(indexPath)
//        //        }
//
//        showIndexPaths = !showIndexPaths
//
//        let animationStyle = showIndexPaths ? UITableView.RowAnimation.right : .left
//
//        tableView.reloadRows(at: indexPathsToReload, with: animationStyle)
//    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.delegate = self

        
        for viewController in tabBarController?.viewControllers ?? [] {
            if let navigationVC = viewController as? UINavigationController, let rootVC = navigationVC.viewControllers.first {
                let _ = rootVC.view
            } else {
                let _ = viewController.view
            }
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
//        view.addSubview(searchController.searchBar)
//        // Setup the Search Controller
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search Contacts"
//        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        navigationController?.isNavigationBarHidden = false
   
        let swipeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
        let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-30"), style: .plain, target: self, action: #selector(handleInfo))
        
        listenForMessages()
        navigationItem.rightBarButtonItems = [swipeButton, infoButton]
        messageBadge.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        // Setup the Scope Bar
        //self.searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
//        self.searchController.searchBar.delegate = self
//        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        fetchContacts()
        
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show IndexPath", style: .plain, target: self, action: #selector(handleShowIndexPath))
        
        navigationItem.title = "Contacts"
//        navigationItem.leftItemsSupplementBackButton = true
//        navigationItem.leftBarButtonItem?.title = "👈"
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .plain, target: self, action: #selector(handleBack))
        //UINavigationItem.setLeftBarButton(back)
        tableView.register(ContactsCell.self, forCellReuseIdentifier: cellId)
        //tableView.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
        tableView.reloadData()
    }
    
    @objc fileprivate func handleInfo() {
        hud.textLabel.text = "Crush Contacts: Select the heart next to contacts you have a crush on. If they select the heart on your name as well, you'll be matched in the chats tab!"
        hud.show(in: navigationController!.view)
        hud.dismiss(afterDelay: 5)
    }
    
    @objc func handleMessages() {
        let messageController = MessageController()
        messageBadge.removeFromSuperview()
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
    
    
    let hud = JGProgressHUD(style: .dark)

    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
//    fileprivate var expanded = false

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering() {
//            return filteredContanct.count
//        }
        
        return twoDimensionalArray[section].names.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let cell = ContactsCell(style: .subtitle, reuseIdentifier: cellId)
        
        cell.link = self
        
        cell.selectionStyle = .none
        
//        if isFiltering() {
//            let favoritableContact = filteredContanct[indexPath.section].names[indexPath.row]
//            cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
//            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
//
//            cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
//
//            let phoneString = favoritableContact.contact.phoneNumbers.first?.value.stringValue ?? ""
//
//            let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
//            let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
//            let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
//            let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
//            var phoneCellFinal = String()
//
//            if phoneNoDash.count < 11 {
//                phoneCellFinal = "+1\(phoneNoDash)"
//            }
//            else {
//                phoneCellFinal = phoneNoDash
//            }
//
//            let hasLiked = swipes[phoneCellFinal] as? Int == 1
//
//
//
//            if hasLiked{
//                cell.accessoryView?.tintColor = .red
//
//            }
//            else {
//                cell.accessoryView?.tintColor = #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
//            }
        
            
        
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
        
        if hasLiked {
            cell.accessoryView?.tintColor = .red
            
        }
        else{
            cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
        }
        return cell
    
        //cell.accessoryView?.tintColor = favoritableContact.hasFavorited ? UIColor.red : #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)

    }
    
//    let searchController = UISearchController(searchResultsController: nil)
    
//    func searchBarIsEmpty() -> Bool {
//        // Returns true if the text is empty or nil
//        return searchController.searchBar.text?.isEmpty ?? true
//
//    }
    
//    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        //let favoritableContact = twoDimensionalArray[IndexPath.section].names[IndexPath.row]
//
//        filteredContanct = twoDimensionalArray.filter({( user : ExpandableNames ) -> Bool in
//            //            var favoritableContacts = [FavoritableContact]()
//            //            let names = ExpandableNames(isExpanded: true, names: favoritableContacts)
//            //            self.twoDimensionalArray = [names]
//             user.names.contains(where: { (contact) -> Bool in
//                return contact.contact.givenName.lowercased().contains(searchText.lowercased())
//
//            })
//        })
//
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//
//        })
//    }
//
//    func isFiltering() -> Bool {
//        return searchController.isActive && !searchBarIsEmpty()
//    }
//
 }


//extension FindCrushesTableViewController: UISearchResultsUpdating {
//    // MARK: - UISearchResultsUpdating Delegate
//    func updateSearchResults(for searchController: UISearchController) {
//
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}

    

