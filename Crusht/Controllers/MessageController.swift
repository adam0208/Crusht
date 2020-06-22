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
import FirebaseFirestore
import FirebaseAuth

class MessageController: UITableViewController, UISearchBarDelegate, SettingsControllerDelegate, LoginControllerDelegate, UITabBarControllerDelegate, SchoolDelegate {
    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    var messageArray = [Message]()
    var user: User?
    var users = [User]()

    static var sharedInstance: MessageController?
    
    var fromName = String()
    var didHaveNewMessage = Bool()
    
    let cellId = "cellId"
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        MessageController.sharedInstance = self
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        
        fetchCurrentUser()

        navigationController?.isNavigationBarHidden = false
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.title = "Messages"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        searchController.searchBar.barStyle = .black
        
        // Setup the Search Controller
        view.addSubview(searchController.searchBar)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Messages"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        
        //refresh controll
             self.tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadMessages), for: .valueChanged)
             refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
             let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)]
             let attributedTitle = NSAttributedString(string: "Reloading", attributes: attributes)
             refreshControl?.attributedTitle = attributedTitle
        
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController.searchBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
        self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        checkNewMessage()
        listenForMessages()
    }
    
    // MARK: - Logic
    
    @objc fileprivate func reloadMessages () {
        print("fuck me man")
        messages.removeAll()
        fetchCurrentUser()
        DispatchQueue.main.async {
             self.tableView.refreshControl?.endRefreshing()
          }
    }
    
    func didSendNewMessage() {
        messages.removeAll()
        fetchCurrentUser()
    }
    
      @objc func handleSettings() {
           let settingsController = ViewController()
          // settingsController.delegate = self
        
        //beware of settings delegate
        
           settingsController.user = user
    
           let navController = UINavigationController(rootViewController: settingsController)
           navController.modalPresentationStyle = .fullScreen
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
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if err != nil {
          
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
//            if self.user?.phoneNumber == ""{
//                let loginController = LoginViewController()
//                self.present(loginController, animated: true)
//                
//            }
//            else if self.user?.name == "" {
//                let namecontroller = EnterNameController()
//                namecontroller.phone = self.user?.phoneNumber ?? ""
//                self.present(namecontroller, animated: true)
//
//            }
          
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
    
    @objc fileprivate func handleBack() {
        self.dismiss(animated: true)
    }
    
    fileprivate func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    self.messages.removeAll()
                    self.observeMessages(received: false)
                    self.observeMessages(received: true)
                    
                    self.handleReloadTable()
                    
                }
            }
        }
    }
    
    @objc func handleReloadTable() {
        // This will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func observeMessages(received: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let field = received ? "toId" : "fromId"
        Firestore.firestore().collection("messages").whereField(field, isEqualTo: uid).getDocuments { (snapshot, err) in
            if err != nil { return }
            
            // Create a dictionary with the newest message for each of the chats
            snapshot?.documents.forEach { documentSnapshot in
                let message = Message(dictionary: documentSnapshot.data())
                if self.shouldUpdateMessageDictionary(with: message), let chatPartnerId = message.chatPartnerId() {
                    self.messageDictionary[chatPartnerId] = message
                }
            }
            
            // Create an array with the values of the dictionary, sorted by date
            self.messages = Array(self.messageDictionary.values)
            self.messages.sort { $0.timestamp?.int32Value ?? 0 > $1.timestamp?.int32Value ?? 0 }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func shouldUpdateMessageDictionary(with message: Message) -> Bool {
        guard let chatPartnerId = message.chatPartnerId(),
              let timestamp = message.timestamp else { return false }
        guard let currentMessage = messageDictionary[chatPartnerId],
              let currentTimestamp = currentMessage.timestamp else { return true }
        return timestamp.int32Value > currentTimestamp.int32Value
    }
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messageDictionary.removeAll()
        messageArray.removeAll()
        tableView.reloadData()
        observeMessages(received: true)
        observeMessages(received: false)
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.fromName = fromName
        let navigC = UINavigationController(rootViewController: chatLogController)
        navigC.modalPresentationStyle = .fullScreen
        present(navigC, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return messageArray.count
        }
        if messages.isEmpty == true {
            return 1
        }
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.selectionStyle = .none
        if !messages.isEmpty {
            if isFiltering() {
                let message = messages[indexPath.row]
                cell.message = message
            } else {
                let message = messages[indexPath.row]
                cell.message = message
            }
        } else {
            if messages.isEmpty {
               
                    cell.profileImageView.image = nil
                    cell.textLabel?.text = "No matches yet 😬"
                
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard messages.count > 0 else { return }
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }

        Firestore.firestore().collection("users").document(chatPartnerId).getDocument(completion: { (snapshot, err) in
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else { return }
            var user = User(dictionary: dictionary)
            user.uid = chatPartnerId
            self.showChatControllerForUser(user)
        })
    }
    
    // MARK: - UISearchBar
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
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
    
    // MARK: - SettingsControllerDelegate
    
    func didSaveSettings() {
        messages.removeAll()
        fetchCurrentUser()
    }
    
    // MARK: - LoginControllerDelegate
    
    func didFinishLoggingIn() {
        messages.removeAll()
        fetchCurrentUser()
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
        }
    }
    
}

// MARK: - UISearchResultsUpdating Delegate
extension MessageController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
