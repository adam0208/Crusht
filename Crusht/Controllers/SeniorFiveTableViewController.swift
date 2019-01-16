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
        
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.text = "Date of Post"
        
        return headerLabel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 45
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return section == 0 ? 0 : 1
        return 1
    }
    
    //Need to Change this but whatever for now
    
    var crush1 = String()
    var crush2 = String()
    var crush3 = String()
    var crush4 = String()
    var crush5 = String()
    var comments = String()
    var timestamp = NSNumber()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SeniorFivePostsTableViewCell(style: .default, reuseIdentifier: nil)

        cell.label.text = "\(crush1)\n\(crush2)\n\(crush3)\n\(crush4)\n\(crush5)\n\n\(comments)"
        
        
//        switch indexPath.section {
//        case 1:
//            cell.label.text = posts
//
//        case 2:
//            cell.label.text = "Hello"
//
//        case 3:
//             cell.label.text = "Hello"
//
//        case 4:
//             cell.label.text = "Hello"
//
//        default:
//             cell.label.text = "Hello"
//        }
        
        return cell
    }
    
    var crushes: Crushes?
    
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
                self.crush1 = crushes.crush1 ?? "NOT LOADED"
                self.crush2 = crushes.crush2 ?? "NOT Loaded"
                self.crush3 = crushes.crush3 ?? "NOT Loaded"
                self.crush4 = crushes.crush4 ?? "NOT Loaded"
                self.crush5 = crushes.crush5 ?? "NOT Loaded"
                self.comments = crushes.comments ?? "NOT Loaded"
              
                self.tableView.reloadData()
                
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
