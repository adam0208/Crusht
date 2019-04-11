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
            
            self.fetchFacebookUser()
        }
    }
    
    var fullName: String?
    var school: String?
    var age: Int?
    var photoUrl: String?
    var socialID: String?
    
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
                        print("lililililiilli", temp)
                        Firestore.firestore().collection("users").whereField("fbid", isEqualTo: temp).order(by: "Full Name").start(at: ["A"]).getDocuments(completion: { (snapshot, err) in
                            if let err = err {
                                print("failed getting fb friends", err)
                            }
                            snapshot?.documents.forEach({ (documentSnapshot) in
                                let userDictionary = documentSnapshot.data()
                                let crush = User(dictionary: userDictionary)
                                
                                self.fbArray.append(crush)
                                
                            })
                            
                        })
                    }
                    
                    
                    self.fetchSwipes()
                    
                    
                }
            }
         
            
        })
    }
    
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

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .plain, target: self, action: #selector(handleBack))
        
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
    
    fileprivate var user: User?
    let hud = JGProgressHUD(style: .dark)
    
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
            self.present(userDetailsController, animated: true)
            
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

