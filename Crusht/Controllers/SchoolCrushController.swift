//
//  SchoolCrushController.swift
//  Crusht
//
//  Created by William Kelly on 1/9/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD


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

class SchoolCrushController: UITableViewController, UISearchBarDelegate {
    
    
//    CONTACTS EASILY DOABLE IF YOU GET USERS PHONE NUMBER

    
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
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellId = "cellId"
                
        fetchCurrentUser()
        
        //tableView.register(SchoolTableViewCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .plain, target: self, action: #selector(handleBack))
        //navigationItem.title = "School"
        tableView.register(SchoolTableViewCell.self, forCellReuseIdentifier: cellId)
        
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
        
        // Setup the search footer
       // tableView.tableFooterView = searchFooter
      
    }
    
    fileprivate var user: User?
    let hud = JGProgressHUD(style: .dark)
    
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
                print(err)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
            print(self.user?.phoneNumber ?? "Fuck you")
            
            //self.fetchSwipes()
            self.fetchSchool()
        }
    }
    
    
    var schoolUserDictionary = [String: User]()
    
    fileprivate func fetchSchool() {
        
        let school = user?.school ?? "Your School"
        
        navigationItem.title = school
        
        print(school)
        
        let query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school)
        
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print("failed to fetch user", err)
                self.hud.textLabel.text = "Failed To Fetch user"
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2)
                return
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let crush = User(dictionary: userDictionary)
                let isNotCurrentUser = crush.uid != Auth.auth().currentUser?.uid
                
                if isNotCurrentUser {
                
                self.schoolArray.append(crush)
                    
                }
                
                print(self.schoolArray)
                //                let crushStuff = User(dictionary: userDictionary)
                //                if let crushPartnerId = crushStuff.crushPartnerId() {
                //                    self.schoolUserDictionary[crushPartnerId] = user
                //                    self.users = Array(self.schoolUserDictionary.values)
                //                }
                
                self.schoolArray.sorted(by: { (crush1, crush2) -> Bool in
                    return crush1.name > crush2.name
                })
                
            })
            
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                
            })
            
            self.fetchSwipes()

        }
        
    }
    
    
    
    func hasTappedCrush(cell: UITableViewCell) {
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        print("YOU Have selected something")
        
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
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) {
        
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
            
            self.fetchSwipes()
            
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
            //Firestore.firestore()
            
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
        print(phone, "LLLLLLLLLLLLLLLLLLLL")
        Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: phone).getDocuments { (snapshot, err) in
            
            if let err = err {
                print("Major fuck up", err)
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let cardUID = user.uid!
                print(user.name ?? "Not getting user")
                
                Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, err) in
                    if let err = err {
                        print(err, "getting whatever failed")
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
                        print(err)
                    }
                    
                    
                    if (snapshot?.isEmpty)! {
                        Firestore.firestore().collection("users").document(uid).collection("matches").addDocument(data: docData)
                        
                        
                            Firestore.firestore().collection("users").document(cardUID).collection("matches").addDocument(data: otherDocData)
                    
                            //print(user.name ?? "Hey champ!")
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
                
                self.presentMatchView(cardUID: cardUID)
                
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
        return schoolArray.count
    }
    
//    var hasFavorited = Bool()
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellL = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SchoolTableViewCell
        
        cellL.link = self
        
        if isFiltering() {
          let crush = users[indexPath.row]
            cellL.textLabel?.text = crush.name
            if let profileImageUrl = crush.imageUrl1 {
                cellL.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        } else {
        let crush = schoolArray[indexPath.row]
            cellL.textLabel?.text = crush.name
            if let profileImageUrl = crush.imageUrl1 {
                cellL.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        }
     
        
//        if hasFavorited == true {
//        cellL.starButton.tintColor = .red
//        }
//        else {
//            cellL.starButton.tintColor = .gray
//        }
        
        let crush = schoolArray[indexPath.row]
        
        let hasLiked = swipes[crush.phoneNumber ?? ""] as? Int == 1
        
        if hasLiked {
            cellL.accessoryView?.tintColor = .red
            hasFavorited = true
        }
        else{
        cellL.accessoryView?.tintColor = #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
        }
        return cellL
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

            userDetailsController.cardViewModel = user.toCardViewModel()
            self.present(userDetailsController, animated: true)
            
        })
    }
    
    fileprivate func showProfileForUser(_ user: User) {
        let schoolProfileDetails = SchoolUserDetailsController()
        schoolProfileDetails.user = user
        let navController = UINavigationController(rootViewController: schoolProfileDetails)
        present(navController, animated: true)
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
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
