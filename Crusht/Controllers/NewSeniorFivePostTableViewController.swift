//
//  NewSeniorFivePostTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 1/11/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//


import UIKit
import Firebase
import JGProgressHUD

class NewSeniorFivePostTableViewController: UITableViewController {
    
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
            //print(self.user.name)
            
            self.fetchSchool()
            
            self.tableView.reloadData()
            
        }
    }
    
    var schoolArray = [User]()
    
    fileprivate func fetchSchool() {
        
        let school = user?.school ?? "Your School"
        
        navigationItem.title = school
        
        print(school)
        
        let query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school)
        
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print("failed to fetch user", err)
              
                return
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let crush = User(dictionary: userDictionary)
                
                self.schoolArray.append(crush)
                
            })
        }
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupGradientLayer()
            fetchCurrentUser()
            tableView.tableFooterView = UIView()
            tableView.keyboardDismissMode = .interactive
            setupNavigationItems()
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
            if section == 0 {
                headerLabel.text = "\(user?.name ?? "")" + "'s Crushes"
            }
            
            return headerLabel
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 7
        }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 0 {
                return 30
            }
            else {
            return 15
            }
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return section == 0 ? 0 : 1
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = SeniorFiveTableViewCell(style: .default, reuseIdentifier: nil)
            
            switch indexPath.section {
            case 1:
                cell.textField.placeholder = "Enter Crush"
                cell.textField.addTarget(self, action: #selector(handleNameOne), for: .editingChanged)
                
            case 2 :
                cell.textField.placeholder = "Enter Crush"
                cell.textField.addTarget(self, action: #selector(handleNameTwo), for: .editingChanged)
                
            case 3:
                cell.textField.placeholder = "Enter Crush"
                cell.textField.addTarget(self, action: #selector(handleNameThree), for: .editingChanged)
                
            case 4:
                cell.textField.placeholder = "Enter Crush"
                cell.textField.addTarget(self, action: #selector(handleNameFour), for: .editingChanged)
                
            case 5:
                cell.textField.placeholder = "Enter Crush"
                cell.textField.addTarget(self, action: #selector(handleNameFive), for: .editingChanged)
                
            default:
                cell.textField .placeholder = "Comments"
                cell.textField.addTarget(self, action: #selector(handleComments), for: .editingChanged)
            }
            
            return cell
        }
    
     var crush1 = String()
     var crush2 = String()
     var crush3 = String()
     var crush4 = String()
     var crush5 = String()
    
    var comments = String()
    
    @objc fileprivate func handleNameOne(textField: UITextField) {
        self.crush1 = textField.text ?? ""
    }
    
    @objc fileprivate func handleNameTwo(textField: UITextField) {
        self.crush2 = textField.text ?? ""
    }
    
    @objc fileprivate func handleNameThree(textField: UITextField) {
        self.crush3 = textField.text ?? ""
    }
    
    @objc fileprivate func handleNameFour(textField: UITextField) {
        self.crush4 = textField.text ?? ""
    }
    
    @objc fileprivate func handleNameFive(textField: UITextField) {
        self.crush5 = textField.text ?? ""
    }
    
    @objc fileprivate func handleComments(textField: UITextField) {
        self.comments = textField.text ?? ""
    }
        
        fileprivate func setupNavigationItems() {
            navigationItem.title = "Your Five"
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handleSave))
            
        }
    
    @objc fileprivate func handleSave () {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        let timestamp = Int(Date().timeIntervalSince1970)
        let docData: [String: Any] = [
            "uid": uid,
            "Name of Poster": user?.name ?? "",
            "School": user?.school ?? "",
            "Crush1": crush1,
            "Crush2": crush2,
            "Crush3": crush3,
            "Crush4": crush4,
            "Crush5": crush5,
            "Comments": comments,
            "Likes": 0,
            "timestamp": timestamp as AnyObject
            ]
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Posting"
        hud.show(in: view)
        
        Firestore.firestore().collection("senior-fives").document(user?.school ?? "").collection("posts").addDocument(data: docData){ (err) in
            hud.dismiss()
            if let err = err {
                print("Failed to save post", err)
                return
            }
            self.dismiss(animated: true, completion: {
                print("Dismissal Complete")
            })
        }
        
    }
        
        @objc fileprivate func handleCancel() {
            dismiss(animated: true)
        }
    
    
    
    let gradientLayer = CAGradientLayer()
    
    //    override func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //        gradientLayer.frame = tableView.bounds
    //
    //    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        tableView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 800)
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 800))
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundView = backgroundView
        
    }
}
