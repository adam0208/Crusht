//
//  SeniorFiveTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
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


class SeniorFiveTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    //let cellId = "cellId123123"
    
    var user: User?
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            self.getPosts()
            self.setupNavigationItems()
            
            self.tableView.reloadData()
//            let indexPath = IndexPath(item: self.crushesArray.count - 1, section: self.crushesArray.count - 1)
//            self.tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
            
        }
    }
    
        override func viewDidLoad() {
            fetchCurrentUser()
          
            super.viewDidLoad()
            tableView.tableFooterView = UIView()
            tableView.keyboardDismissMode = .interactive
            //setupNavigationItems()
            tableView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
            
        }
    

    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
   
        let headerLabel = HeaderLabel()
        
        if section == 0 {
            headerLabel.text = "\(user?.school ?? "Your School")'s Crushes"
            headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
        
        return headerLabel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return crushesArray.count
    }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            
            if section == 0 {
            return 40
            }
            else {
                return 10
            }
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = SeniorFivePostsTableViewCell(style: .default, reuseIdentifier: nil)
        let crushes = crushesArray[indexPath.section]
        cell.crush = crushes
        cell.link = self

        return cell
    }
    
    var numberOfLikes = Int()

    
      func handleLike(cell: UITableViewCell) {
        
        print("HI gggggggggg")
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }

        print("HI YOU Are liking this post")
        
        let post = crushesArray[indexPathTapped.section]
        
       

        //var cell = SeniorFivePostsTableViewCell(style: .default, reuseIdentifier: nil)
        Firestore.firestore().collection("senior-fives").document(user?.school ?? "").collection("posts").whereField("Crush1", isEqualTo: post.crush1 ?? "").whereField("Crush2", isEqualTo: post.crush2 ?? "").whereField("Crush3", isEqualTo: post.crush3 ?? "").whereField("Crush4", isEqualTo: post.crush4 ?? "").whereField("Crush5", isEqualTo: post.crush5 ?? "").whereField("Comments", isEqualTo: post.comments ?? "").getDocuments { (snapshot, err) in
            if let err = err {
                print("didn't get posts", err)
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let crushes = Crushes(dictionary: userDictionary)
            let docID = documentSnapshot.documentID
                
                self.addLike(docID: docID, crush1: crushes.crush1 ?? "", crush2: crushes.crush2 ?? "", crush3: crushes.crush3 ?? "", crush4: crushes.crush4 ?? "", crush5: crushes.crush5 ?? "", comments: crushes.comments ?? "", timestamp: crushes.timestamp!, likes: crushes.likes ?? 0, uid: crushes.uid ?? "", nameOfPoster: crushes.name ?? "", school: crushes.school ?? "", indexPath: indexPathTapped)
            
            })
            
        }
         crushesArray.remove(at: indexPathTapped.section)
    }
    
    fileprivate func addLike(docID: String, crush1: String, crush2: String, crush3: String, crush4: String, crush5: String, comments: String, timestamp: NSNumber, likes: Int, uid: String, nameOfPoster: String, school: String, indexPath: IndexPath) {
        let docData: [String: Any] = [
            "Crush1": crush1,
            "Crush2": crush2,
            "Crush3": crush3,
            "Crush4": crush4,
            "Crush5": crush5,
            "Comments": comments,
            "uid": uid,
            "School": school,
            "Name of Poster": nameOfPoster,
            "Likes": likes + 1,
            "timestamp": timestamp as AnyObject
        ]
        Firestore.firestore().collection("senior-fives").document(user?.school ?? "").collection("posts").document(docID).setData(docData)
        
        let userDictionary = docData
        let crushes = Crushes(dictionary: userDictionary)
        self.crushesArray.append(crushes)
        //self.crushDictionary = crushesArray
        self.crushesArray.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value

        })
        
        DispatchQueue.main.async(execute: {
            
           
            self.tableView.reloadData()
            self.tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
        })
        
        
//        crushesArray.removeAll()
//
//        getPosts()
    }
    
    var crushes: Crushes?
    
    var crushesArray = [Crushes]()
    
    var crushDictionary = [String: Crushes]()
    
    //var userSchool = String()
    
    fileprivate func getPosts() {
   
        let hud = JGProgressHUD(style: .dark)
      
        Firestore.firestore().collection("senior-fives").document(user?.school ?? "").collection("posts").getDocuments { (snapshot, err) in
            if let err = err {
                print("didn't get posts", err)
                hud.textLabel.text = "Couldn't Get Posts. Maybe Have Better Internet Next Time"
                hud.show(in: self.view)
                hud.dismiss()
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let crushes = Crushes(dictionary: userDictionary)

                self.crushesArray.append(crushes)
                //self.crushDictionary = crushesArray
                self.crushesArray.sort(by: { (message1, message2) -> Bool in
                    return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                    //refactor to cut cost
                })
                
                DispatchQueue.main.async(execute: {
                  
              
                self.tableView.reloadData()
                })
                
                }
            )}
        }
    
    
        fileprivate func setupNavigationItems() {
            navigationItem.title = "Crush List"
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Write Your 5", style: .plain, target: self, action: #selector(handleWritePost))
        }
        
        @objc fileprivate func handleCancel() {
            dismiss(animated: true)
        }
    
    @objc fileprivate func handleWritePost() {
        let seniorFivePostController = NewSeniorFivePostTableViewController()
        let navcontroller = UINavigationController(rootViewController: seniorFivePostController)
        present(navcontroller, animated: true)
    }
    
//this is buggy as hell
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            if tableView.contentOffset.y < -70 {
                fetchCurrentUser()
              
            }
        }
    }
        
}
