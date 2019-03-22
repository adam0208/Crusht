//
//  NewMessageController.swift
//  Crusht
//
//  Created by William Kelly on 12/15/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.title = "New Message"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchSwipes()
        fetchPhoneSwipes()
        
        fetchUser()
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
        }
    }
    
    var phoneSwipes = [String: Int]()
    
    func fetchPhoneSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        Firestore.firestore().collection("phone-swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            print("Swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.phoneSwipes = data
            
        }
    }
    
    func fetchUser() {
//        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
        
        //handle only matched users
        
        //maybe add a matches document in the database
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("users").document(uid).collection("matches").getDocuments { (snapshot, err) in
            
            if let err = err {
                print("FAILLLLLLLLL", err)
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
                //                user.name = dictionary["name"]
            })
            
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.school
        
        if let profileImageUrl = user.imageUrl1 {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController = MessageController()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            
            self.messagesController.showChatControllerForUser(user)
        }
    }
    
}

//class UserCell: UITableViewCell {
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
//
//        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
//    }
//
//    let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 24
//        imageView.layer.masksToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
//
//        addSubview(profileImageView)
//
//        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
//        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
