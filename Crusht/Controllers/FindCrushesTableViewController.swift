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
import Alamofire

class FindCrushesTableViewController: UITableViewController {
    
    

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
            //self.fetchSwipes()
            
        }
    }
    

    // you should use Custom Delegation properly instead
    func someMethodIWantToCall(cell: UITableViewCell) {

        // we're going to figure out which name we're clicking on
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let contact = twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row]
        print(contact)
        
        let hasFavorited = contact.hasFavorited
        twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row].hasFavorited = !hasFavorited
        
        phoneID = contact.contact.phoneNumbers.first?.value.stringValue ?? ""
        
        cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
        
        handleLike()
    }
    
    //func sendMessageToNewUser() {
    
//        var swiftRequest = SwiftRequest();
//        
//        var data = [
//            "To" : "+15555555555",
//            "From" : "+15555556666",
//            "Body" : "Hello World"
//        ];
//        
//        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts/[YOUR_ACCOUNT_SID]/Messages",
//                          auth: ["username" : "[YOUR_ACCOUNT_SID]", "password" : "YOUR_AUTH_TOKEN"]
//            data: data,
//            callback: {err, response, body in
//                if err == nil {
//                    println("Success: \(response)")
//                } else {
//                    println("Error: \(err)")
//                }
//        });
//}
    
    var phoneID: String?
    
    var twoDimensionalArray = [ExpandableNames]()
    
    
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
                        
                        //                        favoritableContacts.append(FavoritableContact(name: contact.givenName + " " + contact.familyName, hasFavorited: false))
                    })
                    
                    let names = ExpandableNames(isExpanded: true, names: favoritableContacts)
                    self.twoDimensionalArray = [names]
                    
                } catch let err {
                    print("Failed to enumerate contacts:", err)
                }
                
            } else {
                print("Access denied..")
            }
        }
    }
    
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

        //LOT OF TRIMMING AND STRIPPING
        
        let cardUID = phoneNoDash
        
        let documentData = [cardUID: didLike]
        
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
        let phone = phoneNumber
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
            
            if let err = err {
                print("Major fuck up", err)
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let cardUID = user.uid!
                //self.crushScoreID = cardUID
                self.presentMatchView(cardUID: cardUID)
                
            })
        }
       
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
        }
    }
    
    func handleLike() {
        
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        
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

        fetchCurrentUser()
        fetchContacts()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show IndexPath", style: .plain, target: self, action: #selector(handleShowIndexPath))
        
        navigationItem.title = "Contacts"
    
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        //UINavigationItem.setLeftBarButton(back)
        tableView.register(ContactsCell.self, forCellReuseIdentifier: cellId)
        //tableView.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
        
    }
    
    let hud = JGProgressHUD(style: .dark)

    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        
        let button = UIButton(frame: CGRect(x:headerView.frame.size.width - 2*headerView.frame.size.width/3, y:0, width:headerView.frame.size.width/3, height:30))
        button.setTitle("Contacts", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        //button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.tag = section
        
        let FBFreindbutton = UIButton(frame: CGRect(x:headerView.frame.size.width - headerView.frame.size.width/3, y:0, width:headerView.frame.size.width/3, height:30))
        FBFreindbutton.setTitle("FB Friends", for: .normal)
        FBFreindbutton.setTitleColor(.black, for: .normal)
        FBFreindbutton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        FBFreindbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        FBFreindbutton.addTarget(self, action: #selector(handleFBExpandClose), for: .touchUpInside)
        
        FBFreindbutton.tag = section
        
        let SchoolBttn = UIButton(frame: CGRect(x:headerView.frame.size.width - headerView.frame.size.width, y:0, width:headerView.frame.size.width/3, height:30))
        SchoolBttn.setTitle("School", for: .normal)
        SchoolBttn.setTitleColor(.black, for: .normal)
        SchoolBttn.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        SchoolBttn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        SchoolBttn.addTarget(self, action: #selector(goToSchool), for: .touchUpInside)
        
        SchoolBttn.tag = section
        
        headerView.addSubview(button)
        headerView.addSubview(FBFreindbutton)
        headerView.addSubview(SchoolBttn)
        
        return headerView
        
    }
    
    fileprivate var expanded = false
    
    @objc func goToSchool() {
        let schoolController = SchoolCrushController()
        let navControlla = UINavigationController(rootViewController: schoolController)
        present(navControlla, animated: true)
    }
    
//    @objc func handleSchoolExpandClose(button: UIButton) {
//
//        let section = button.tag
//
//        let names = schoolArray.count
//
//        // we'll try to close the section first by deleting the rows
//        var indexPaths = [IndexPath]()
//        for row in schoolArray[section].description.indices{
//            print(0, row)
//            let indexPath = IndexPath(row: names, section: section)
//            indexPaths.append(indexPath)
//        }
//
//        button.setTitle(expanded ? "School" : "School", for: .normal)
//
//        if expanded {
//            tableView.deleteRows(at: indexPaths, with: .fade)
//        } else {
//            tableView.beginUpdates()
//            tableView.insertRows(at: indexPaths, with: .fade)
//            tableView.endUpdates()
//        }
//    }
    
    @objc func handleFBExpandClose(button: UIButton) {
        print("expanding")
        
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        for row in twoDimensionalArray[section].names.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = twoDimensionalArray[section].isExpanded
        twoDimensionalArray[section].isExpanded = !isExpanded
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    @objc func handleExpandClose(button: UIButton) {
        print("Trying to expand and close section...")
        
        let section = button.tag
        
        // we'll try to close the section first by deleting the rows
        var indexPaths = [IndexPath]()
        for row in twoDimensionalArray[section].names.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = twoDimensionalArray[section].isExpanded
        twoDimensionalArray[section].isExpanded = !isExpanded
        
        button.setTitle(isExpanded ? "Contacts" : "Contacts", for: .normal)
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimensionalArray[section].isExpanded {
            return 0
        }
        
        return twoDimensionalArray[section].names.count
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 10))
//        view.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
//
//        return view
//    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10.0
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let cell = ContactsCell(style: .subtitle, reuseIdentifier: cellId)
        
        cell.link = self
        
        let favoritableContact = twoDimensionalArray[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
        
        cell.accessoryView?.tintColor = favoritableContact.hasFavorited ? UIColor.red : #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
        
        if showIndexPaths {
            //            cell.textLabel?.text = "\(favoritableContact.name)   Section:\(indexPath.section) Row:\(indexPath.row)"
        }
        
        return cell
    }
    
    
}
