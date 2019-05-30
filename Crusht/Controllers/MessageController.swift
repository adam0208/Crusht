//
//  MessageTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GeoFire
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

class MessageController: UITableViewController, UISearchBarDelegate, SettingsControllerDelegate, LoginControllerDelegate, UITabBarControllerDelegate, SchoolDelegate {
    func didSendNewMessage() {
        messages.removeAll()
        fetchCurrentUser()
    }
    
    var didHaveNewMessage = Bool()
    static var sharedInstance: MessageController?
    
    func didSaveSettings() {
        messages.removeAll()
        fetchCurrentUser()
    }
    
    
    func didFinishLoggingIn() {
        messages.removeAll()
        fetchCurrentUser()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        }
    }
    
    //ADD COLLECTION CALLED USER MESSAGE OR SOMETING TO DOCUMENT SO ONLY GET ONE MESSAGE

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
        self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        checkNewMessage()

        listenForMessages()
    }
    
    var user: User?
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
        
    }
    
    @objc fileprivate func handleMatchByLocationBttnTapped() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                showSettingsAlert2()
            case .authorizedAlways, .authorizedWhenInUse:
                let locationViewController = LocationMatchViewController()
                locationViewController.user = user
                let navigationController = UINavigationController(rootViewController: locationViewController)
                present(navigationController, animated: true)
            }
        } else {
            showSettingsAlert2()
        }
        
        
    }
    
    
    private func showSettingsAlert2() {
        let alert = UIAlertController(title: "Enable Location", message: "Crusht would like to use your location to match you with nearby users.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            return
        })
        present(alert, animated: true)
    }
    
    let hud = JGProgressHUD(style: .dark)
    
     func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                self.hud.textLabel.text = "Something went wrong! Just log in again!"
                self.hud.show(in: self.navigationController!.view)
                self.hud.dismiss(afterDelay: 2)
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
            if self.user?.phoneNumber == ""{
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
                
            }
            else if self.user?.name == "" {
                let namecontroller = EnterNameController()
                namecontroller.phone = self.user?.phoneNumber ?? ""
                self.present(namecontroller, animated: true)
                
            }
          
            self.fromName = self.user?.name ?? "Match"
            self.setupNavBarWithUser(self.user!)
        }
        
    }

    
    fileprivate func checkNewMessage() {
        if didHaveNewMessage == true {
            didHaveNewMessage = false
            fetchCurrentUser()
        }
    }
    
    override func viewDidLoad() {
        MessageController.sharedInstance = self
        super.viewDidLoad()
        let cellId = "cellId"
        self.tabBarController?.delegate = self

        fetchCurrentUser()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
        
         navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        
        navigationController?.isNavigationBarHidden = false

//        navigationItem.leftItemsSupplementBackButton = true
//        navigationItem.leftBarButtonItem?.title = "👈"
        
      //  let image = UIImage(named: "new_message_icon")?.withRenderingMode(.alwaysOriginal)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        navigationItem.title = "Messages"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        searchController.searchBar.barStyle = .black
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Messages"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        
       
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController.searchBar.tintColor = .white
       
        
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
                return
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
                
             
                //changeHandler: nil)
            })
            
        })
    }
    
    fileprivate func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                    }
                    if (diff.type == .modified) {
                        self.messages.removeAll()
                        self.observeMessages()
                        self.observeUserMessages()
                        
                        self.handleReloadTable()
                        
                    }
                    if (diff.type == .removed) {
                    }
                }
        }
    }
    
   
    
    @objc func handleReloadTable() {
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: uid).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                return
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
        
        if messages.isEmpty == false {
        
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
        

        }
        else {
            self.messages.removeAll()
            self.observeMessages()
            self.observeUserMessages()
            
            self.handleReloadTable()
        }
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
    
        

    
    var fromName = String()
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        messageArray.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        observeMessages()
        

//        let titleView = UIView()
//        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        //        titleView.backgroundColor = UIColor.redColor()
//
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        titleView.addSubview(containerView)
//
//        let profileImageView = UIImageView()
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.cornerRadius = 20
//        profileImageView.clipsToBounds = true
//        if let profileImageUrl = user.imageUrl1 {
//            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
//
//        containerView.addSubview(profileImageView)
//
//        //ios 9 constraint anchors
//        //need x,y,width,height anchors
//        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//        let nameLabel = UILabel()
//
//        containerView.addSubview(nameLabel)
//        nameLabel.text = user.name
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        //need x,y,width,height anchors
//        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
//        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
//        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
//
//        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//
//        self.navigationItem.titleView = titleView
//
//        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.fromName = fromName
        let navigC = UINavigationController(rootViewController: chatLogController)
       present(navigC, animated: true)
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

//public extension UISearchBar {
//
//    public func setTextColor(color: UIColor) {
//        let svs = subviews.flatMap { $0.subviews }
//        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
//        tf.textColor = .white
//    }
//}


