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

//two dimensinoal array not necessary

//struct schoolshit {
//    var uids: String
//    var names: String
//}

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

class SchoolCrushController: UITableViewController {
    
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        //navigationItem.title = "School"
        tableView.register(SchoolTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    fileprivate var user: User?
    let hud = JGProgressHUD(style: .dark)
    
    var schoolArray = [User]()
    
    var users = [User]()
    
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
            self.fetchSchool()
        }
    }
    
    
    var schoolUserDictionary = [String: User]()
    
    fileprivate func fetchSchool() {
        
        print("Fetching School Stuff ahahahahahah")
        
        let school = user?.school ?? "I suck a lot"
        
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
                
                self.schoolArray.append(crush)
                
                
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
        }
        
    }
    
    var hasCrushed = Bool()
    
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
        
        tableView.reloadRows(at: [indexPathTapped], with: .fade)
        
        
        cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
        
        handleLike()
        
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
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("we have a match!")
                self.getCardUID(phoneNumber: cardUID)
            }
        }
    }
    
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
            
            
        }
    }
    
    func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        self.navigationController?.view.addSubview(matchView)
        matchView.bringSubviewToFront(view)
        matchView.fillSuperview()
    }
    
    // MARK: - Table view data source
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolArray.count
    }
    
    fileprivate var hasFavorited = false
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellL = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SchoolTableViewCell
        
        cellL.link = self
        
        let crush = schoolArray[indexPath.row]
        cellL.textLabel?.text = crush.name
        if let profileImageUrl = crush.imageUrl1 {
            cellL.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        cellL.starButton.tintColor = hasFavorited ? UIColor.red : #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
        
        return cellL
    }
    
    func handleLike() {
        
        
        saveSwipeToFireStore(didLike: 1)
        addCrushScore()
        
        //cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
}
