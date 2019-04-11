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
        print(contact)
        
        let hasFavorited = contact.hasFavorited
        twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row].hasFavorited = !hasFavorited
        
        let phoneString = contact.contact.phoneNumbers.first?.value.stringValue ?? ""
        
        phoneID = phoneString
        
        cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) {
            
            handleLike()
        }
        else {
            handleDislike()
        }
    }
//    func sendMessageToNewUser() {
//
//        var swiftRequest = SwiftRequest();
//
//        var data = [
//            "To" : "+15555555555",
//            "From" : "+15555556666",
//            "Body" : "Hello World"
//        ];
//
//        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts/[YOUR_ACCOUNT_SID]/Messages", auth: ["username" : "[YOUR_ACCOUNT_SID]", "password" : "YOUR_AUTH_TOKEN"]
//            data: data,
//            callback: {err, response, body in
//                if err == nil {
//                    println("Success: \(response)")
//                } else {
//                    println("Error: \(err)")
//                }
//        });
//    }
//
    var phoneID: String?

    var twoDimensionalArray = [ExpandableNames]()
    var filteredContanct = [ExpandableNames]()

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

                do {

                    var favoritableContacts = [FavoritableContact]()

                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in

                        print(contact.givenName)
                        print(contact.familyName)
                        print(contact.phoneNumbers.first?.value.stringValue ?? "")

                        favoritableContacts.append(FavoritableContact(contact: contact, hasFavorited: false))

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
                self.presentMatchView(cardUID: cardUID)
                
            })
        }
       
    }
    
    var crushScoreID = String()
    
    func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        matchView.sendMessageButton.addTarget(self, action: #selector(handleMessageButtonTapped), for: .touchUpInside)
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
    
    func handleLike() {
        
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        
    }
    
   func handleDislike() {
    saveSwipeToFireStore(didLike: 0)
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
        
        
        let hasLiked = swipes[phoneNoDash] as? Int == 1
        
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
        
        filteredContanct = twoDimensionalArray.filter({( user : ExpandableNames) -> Bool in
//            var favoritableContacts = [FavoritableContact]()
//            let names = ExpandableNames(isExpanded: true, names: favoritableContacts)
//            self.twoDimensionalArray = [names]
            return user.names.description.lowercased().contains(searchText.lowercased())
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
    
    

