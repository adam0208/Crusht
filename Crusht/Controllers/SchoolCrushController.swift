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

class SchoolCrushController: UITableViewController {
    
    
//    CONTACTS EASILY DOABLE IF YOU GET USERS PHONE NUMBER
    
    let cellId = "cellId123123"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchCurrentUser()
        
        tableView.register(SchoolTableViewCell.self, forCellReuseIdentifier: cellId)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        //navigationItem.title = "School"
    }
    
    fileprivate var user: User?
    let hud = JGProgressHUD(style: .dark)
    
    var schoolArray = [String]()
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
            
            //self.fetchSwipes()
            self.fetchSchool()
        }
    }
    
    var matchUID = [String]()
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
                let user = User(dictionary: userDictionary)
                self.matchUID.append(user.uid!)
                print(self.matchUID)
                //need to figure out how to grab uid
                //two dimensional array maybe!
                self.schoolArray.append(user.name!)
                print(self.schoolArray)
                let crushStuff = User(dictionary: userDictionary)
                if let crushPartnerId = crushStuff.crushPartnerId() {
                    self.schoolUserDictionary[crushPartnerId] = user
                    self.users = Array(self.schoolUserDictionary.values)
                }
                self.tableView.reloadData()
                
                }
            )}
    }
    
    var hasCrushed = Bool()
    
    func hasTappedCrush(cell: UITableViewCell) {
        //        print("Inside of ViewController now...")
        
        // we're going to figure out which name we're clicking on
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let name = schoolArray[indexPathTapped.row]
            print(name)
        
        handleLike()
        
//        let contact = twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row]
//        print(contact)
        
        
    
        //        tableView.reloadRows(at: [indexPathTapped], with: .fade)
        
        
        
        cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red
    }
    
    func saveSwipeToFireStore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
         let cardUID = matchUID[4]
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe doc", err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
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
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
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
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
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
                self.presentMatchView(cardUID: cardUID)
            }
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            print("Swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
            // self.fetchUsersFromFirestore()
            //self.fetchUsersOnLoad()
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolArray.count
    }
    
    fileprivate var hasFavorited = false
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellL = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SchoolTableViewCell
        
        cellL.link = self
        
        let name = schoolArray[indexPath.row]
        
        cellL.nameText.text = name
        
        cellL.starButton.tintColor = hasFavorited ? UIColor.red : #colorLiteral(red: 0.8693239689, green: 0.8693239689, blue: 0.8693239689, alpha: 1)
        
        return cellL
    }
    
      func handleLike() {
        
        
        saveSwipeToFireStore(didLike: 1)
        
        //cell.accessoryView?.tintColor = hasFavorited ? #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1) : .red

    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }

}
