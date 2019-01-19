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
            self.setupNavigationItems()
            
            self.tableView.reloadData()
        }
    }
    
        override func viewDidLoad() {
            fetchCurrentUser()
            getPosts()
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
        
        return headerLabel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return crushesArray.count
    }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 20
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = SeniorFivePostsTableViewCell(style: .default, reuseIdentifier: nil)
        let crushes = crushesArray[indexPath.section]
        cell.crush = crushes
        
        
        return cell
    }
    
    var crushes: Crushes?
    
    var crushesArray = [Crushes]()
    
    var crushDictionary = [String: Crushes]()
    
    fileprivate func getPosts() {
        let hud = JGProgressHUD(style: .dark)
        Firestore.firestore().collection("senior-fives").getDocuments { (snapshot, err) in
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
            navigationItem.title = "\(user?.school ?? " Senior Fives")" + "'s Senior Fives"
            
            navigationController?.navigationBar.prefersLargeTitles = true
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
        
}
