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
import AudioToolbox
import CoreLocation
import GeoFire
import FirebaseFirestore
import FirebaseAuth


class ContactsController: UITableViewController, UISearchBarDelegate, LoginControllerDelegate, UITabBarControllerDelegate {
    
    var expandableContacts = ExpandableContacts(isExpanded: true, contacts: [])
    lazy var filteredExpandableContacts = ExpandableContacts(isExpanded: true, contacts: [])
    
    var users = [User]()
    var user: User?
    
    private var crushScore: CrushScore?
    var crushScoreID = String()
    
    var phoneFinal = String()
    var showIndexPaths = false
    var swipes = [String: Int]()
    
    let messageController = MessageController()
    let searchController = UISearchController(searchResultsController: nil)
    
    let cellId = "cellId123123"
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
         super.viewDidLoad()
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
         
         // Setup the Search Controller
         view.addSubview(searchController.searchBar)
         searchController.searchResultsUpdater = self
         searchController.obscuresBackgroundDuringPresentation = false
         searchController.searchBar.placeholder = "Search Contacts"
         searchController.searchBar.barStyle = .black
         searchController.searchBar.tintColor = .white
         navigationItem.searchController = self.searchController
         definesPresentationContext = true
         navigationController?.isNavigationBarHidden = false
         
         listenForMessages()
         messageBadge.isHidden = true
         
         navigationController?.navigationBar.isTranslucent = false
         
         // Setup the Scope Bar
         self.searchController.searchBar.delegate = self
         self.navigationItem.hidesSearchBarWhenScrolling = false
         navigationItem.title = "Contacts"
         tableView.register(ContactsCell.self, forCellReuseIdentifier: cellId)
         tableView.reloadData()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        if UIApplication.shared.applicationIconBadgeNumber == 1 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
        }
        handleContacts()
      
        tableView.reloadData()
    }
    
    // MARK: - Logic
    
    fileprivate func handleContacts() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {

        case .authorized:
            fetchContacts()
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
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if err != nil {
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
        
           self.fetchSwipes()
        }
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

    // You should use Custom Delegation properly instead
    func someMethodIWantToCall(cell: UITableViewCell) {
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        let contact = isFiltering() ? filteredExpandableContacts.contacts[indexPathTapped.row] : expandableContacts.contacts[indexPathTapped.row]
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) {
            handleLike(contact: contact, cell: cell)
        } else {
            handleDislike(contact: contact, cell: cell)
        }
    }

    fileprivate func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if err != nil {
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
                    })

                    self.expandableContacts = ExpandableContacts(isExpanded: true, contacts: favoritableContacts)
                    
                    self.fetchCurrentUser()
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                    
                } catch { }
            } else {
                print("Access denied..")
            }
        }
    }
    
    func saveSwipeLocally(contact: FavoritableContact, didLike: Int) {
        let phoneString = contact.phoneCell
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        swipes[phoneNoDash] = didLike
    }
    
    func saveSwipeToFireStore(contact: FavoritableContact, didLike: Int) {
        let phoneNumber = user?.phoneNumber ?? ""
        
        let phoneString = contact.phoneCell
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        let cardUID = phoneNoDash
        
        print(cardUID, "Maya did it right")
        
        let twilioPhoneData: [String: Any] = ["phoneToInvite": phoneFinal]
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phoneFinal).getDocuments { (snapshot, err) in
            if err != nil {
                return
            }
           
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("twilio-invites").addDocument(data: twilioPhoneData)
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
                    if err != nil {
                        return
                    }
                    if snapshot?.exists == true {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).updateData(documentData) { (err) in
                            if err != nil {
                                return
                            }
                            if didLike == 1 {
                                self.checkIfMatchExists(cardUID: cardUID)
                            }
                        }
                    } else {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).setData(documentData) { (err) in
                            if err != nil {
                                return
                            }
                            if didLike == 1 {
                                self.checkIfMatchExists(cardUID: cardUID)
                            }
                        }
                    }
                }
            } else {
        
                Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
                    if err != nil {
                        return
                    }
                    if snapshot?.exists == true {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).updateData(documentData) { (err) in
                            if err != nil {
                                return
                            }
                            if didLike == 1 {
                                self.checkIfMatchExists(cardUID: cardUID)
                            }
                        }
                    } else {
                        Firestore.firestore().collection("phone-swipes").document(phoneNumber).setData(documentData) { (err) in
                            if err != nil {
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
            if err != nil {
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
      
    fileprivate func getCardUID(phoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let phone = phoneNumber
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let cardUID = user.uid!
                
                let docData: [String: Any] = ["uid": cardUID, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!]
                let otherDocData: [String: Any] = ["uid": uid, "Full Name": user.name ?? "", "School": user.school ?? "", "ImageUrl1": user.imageUrl1!]
                
                Firestore.firestore().collection("users").document(uid).collection("matches").whereField("uid", isEqualTo: cardUID).getDocuments(completion: { (snapshot, err) in
                    if (snapshot?.isEmpty)! {
                        Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                        Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
                        self.handleSend(cardUID: cardUID, cardName: user.name ?? "")
                    }
                })
            })
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
        
    fileprivate func fetchSwipes() {
       let phoneNumber = user?.phoneNumber ?? ""
        Firestore.firestore().collection("phone-swipes").document(phoneNumber).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func handleLike(contact: FavoritableContact, cell: UITableViewCell) {
        saveSwipeLocally(contact: contact, didLike: 1)
        saveSwipeToFireStore(contact: contact, didLike: 1)
        cell.accessoryView?.tintColor = .red
    }
    
    func handleDislike(contact: FavoritableContact, cell: UITableViewCell) {
        saveSwipeLocally(contact: contact, didLike: 0)
        saveSwipeToFireStore(contact: contact, didLike: 0)
        cell.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
    }
    
    @objc func handleMessages() {
        let messageController = MessageController()
        messageBadge.removeFromSuperview()
        messageController.user = user
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
        //navigationController?.pushViewController(messageController, animated: true)
        
    }
    
    fileprivate func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
                    self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
                    UIApplication.shared.applicationIconBadgeNumber = 1
                   // AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
        }
    }
    
       @objc func handleSettings() {
           let settingsController = ViewController()
          // settingsController.delegate = self
           settingsController.user = user
    
           let navController = UINavigationController(rootViewController: settingsController)
           navController.modalPresentationStyle = .fullScreen
           present(navController, animated: false)
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

    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredExpandableContacts.contacts.count : expandableContacts.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoritableContact = isFiltering() ? filteredExpandableContacts.contacts[indexPath.row] : expandableContacts.contacts[indexPath.row]
        let hasLiked = swipes[favoritableContact.phoneCell] == 1
        let cell = ContactsCell(style: .subtitle, reuseIdentifier: cellId)
        cell.setup(favoritableContact: favoritableContact, hasLiked: hasLiked)
//        let phoneString = favoritableContact.phoneCell
//                        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
//                        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
//                        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
//                        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
//        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phoneNoDash).getDocuments { (snap, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            snap?.documents.forEach({ (docSnap) in
//                let userDictionary = docSnap.data()
//                let user = User(dictionary: userDictionary)
//                if docSnap.exists {
//                    cell.setup2(crush: user, hasFavorited: hasLiked)
//                }
//            })
//        }
        cell.link = self
        return cell
    }
    
    // MARK: - LoginControllerDelegate
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        }
    }
    
    // MARK: - SettingsControllerDelegate
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    // MARK: - UISearchBar
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredExpandableContacts = expandableContacts.filterBy(text: searchText)
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - User Interface
    
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
}

// MARK: - UISearchResultsUpdating
extension ContactsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
