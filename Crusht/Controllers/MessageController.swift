//
//  MessageTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase

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

class MessageController: UITableViewController, UISearchBarDelegate {
    
    let badge: UILabel = {
    let label = UILabel(frame: CGRect(x: 10, y: -10, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
    label.layer.borderWidth = 2
    label.layer.cornerRadius = label.bounds.size.height / 2
    label.textAlignment = .center
    label.layer.masksToBounds = true
    label.font = UIFont(name: "SanFranciscoText-Light", size: 13)
    label.textColor = .white
    label.backgroundColor = .red
    label.text = "80"
        return label
    }()
    
    //ADD COLLECTION CALLED USER MESSAGE OR SOMETING TO DOCUMENT SO ONLY GET ONE MESSAGE

    override func viewDidLoad() {
        super.viewDidLoad()
        let cellId = "cellId"
        
        navigationController?.isNavigationBarHidden = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .plain, target: self, action: #selector(handleBack))
//        navigationItem.leftItemsSupplementBackButton = true
//        navigationItem.leftBarButtonItem?.title = "👈"
        
      //  let image = UIImage(named: "new_message_icon")?.withRenderingMode(.alwaysOriginal)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        navigationItem.title = "Messages"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        
        fetchUserAndSetupNavBarTitle()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: true)
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Messages"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        
        
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc fileprivate func handleBack() {
        self.dismiss(animated: true)
    }
  
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
      var messageArray = [Message]()
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //Firestore.firestore.coll
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: uid).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("HELLLLLLLLNO", err)
            }
            
            //need to use where call and set it to from id
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let message = Message(dictionary: userDictionary)
                self.messages.append(message)
             
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                let messageStuff = Message(dictionary: userDictionary)
                
                if let chatPartnerId = messageStuff.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                        //refactor to cut cost
                    })
                }
                
                self.timer?.invalidate()
                print("we just canceled our timer")
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                
                //changeHandler: nil)
            })
            
        })
    }
    
    fileprivate func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                    }
                    if (diff.type == .modified) {
                        self.handleReloadTable()
                        
                    }
                    if (diff.type == .removed) {
                    }
                }
        }
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            print("we reloaded the table")
            self.tableView.reloadData()
        })
    }

    
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: uid).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("FAILLLLLLLLL", err)
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let message = Message(dictionary: userDictionary)
                
                self.messages.append(message)
                
                let messageStuff = Message(dictionary: userDictionary)
                
                if let chatPartnerId = messageStuff.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                        //refactor to cut cost
                    })
                }
                
                DispatchQueue.main.async(execute: {
                    
                    self.tableView.reloadData()
                })
                
            })
            
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    var users = [User]()
    
    //search bar stuff
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        messageArray = messages.filter({( message : Message) -> Bool in
            return message.toName!.lowercased().contains(searchText.lowercased())
            
        })
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return messageArray.count
        }
        return messages.count
    }
    
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        //let user = users[indexPath.row]
        
      
        
        if isFiltering() {
            let message = messages[indexPath.row]
            cell.message = message
        } else {
            let message = messages[indexPath.row]
            cell.message = message
        }
        
//        let message = messages[indexPath.row]
//        cell.textLabel?.text = message.toName
//        cell.detailTextLabel?.text = message.text
//
//        if let profileImageUrl = user.imageUrl1 {
//            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
//        let ref = Database.database().reference().child("users").child(chatPartnerId)
//        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                return
//            }
        Firestore.firestore().collection("users").document(chatPartnerId).getDocument(completion: { (snapshot, err) in
                guard let dictionary = snapshot?.data() as [String: AnyObject]? else {return}
        
            
                var user = User(dictionary: dictionary)
            user.uid = chatPartnerId
            self.showChatControllerForUser(user)
            
        })
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
//        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        
    Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
        
            if let dictionary = snapshot?.data() {
                self.navigationItem.title = dictionary["Full Name"] as? String

                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
        }
        
    }
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        observeMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.redColor()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.imageUrl1 {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.fromName = navigationItem.title
        let myBackButton = UIBarButtonItem()
        
        myBackButton.title = "👈"
        navigationItem.backBarButtonItem = myBackButton
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension MessageController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

    

