//
//  PartyListController.swift
//  Crusht
//
//  Created by William Kelly on 1/29/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class PartyListController: UITableViewController, SettingsControllerDelegate, UISearchBarDelegate {
    func didSaveSettings() {
        partiesArray.removeAll()
        fetchCurrentUser()
    }
    
    let cellId = "cellId"
    var user: User?
    var partiesArray = [Party]()
    var parties = [Party]()
    
    let messageBadge: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        label.backgroundColor = .red
        label.text = "!"
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
                
                tableView.register(PartyCell.self, forCellReuseIdentifier: cellId)

//                let swipeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
//                let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-30"), style: .plain, target: self, action: #selector(handleInfo))
//
                listenForMessages()
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create Event", style: .plain, target: self, action: #selector(handleCreateEvent))
                
                // Setup the Search Controller
                view.addSubview(searchController.searchBar)
                searchController.searchResultsUpdater = self
                searchController.obscuresBackgroundDuringPresentation = false
                searchController.searchBar.placeholder = "Search Parties"
                navigationItem.searchController = self.searchController
                definesPresentationContext = true
                   
                // Setup the Scope Bar
               self.searchController.searchBar.delegate = self
            self.navigationItem.hidesSearchBarWhenScrolling = false
                messageBadge.isHidden = true
                
                //refresh controll
                self.tableView.refreshControl = UIRefreshControl()
                refreshControl?.addTarget(self, action: #selector(reloadParty), for: .valueChanged)
                refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
                let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)]
                let attributedTitle = NSAttributedString(string: "Reloading", attributes: attributes)
                refreshControl?.attributedTitle = attributedTitle
                self.navigationItem.title = "Your Parties"

                 //Setup the search footer
                navigationController?.navigationBar.isTranslucent = false
                navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
                searchController.searchBar.barStyle = .black
                navigationController?.navigationBar.prefersLargeTitles = true
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                fetchCurrentUser()

    }
    
    @objc fileprivate func handleCreateEvent() {
        let newPartyController = NewPartyController()
        newPartyController.phoneNumber = user?.phoneNumber ?? ""
        let navController = UINavigationController(rootViewController: newPartyController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc fileprivate func reloadParty () {
        print("fuck me man")
        partiesArray.removeAll()
        fetchCurrentUser()
        DispatchQueue.main.async {
             self.tableView.refreshControl?.endRefreshing()
          }
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
//        let myBackButton = UIBarButtonItem()
//        myBackButton.title = " "
//        self.navigationItem.backBarButtonItem = myBackButton
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
//    @objc fileprivate func handleMatchByLocationBttnTapped() {
//        if CLLocationManager.locationServicesEnabled() {
//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied:
//                showSettingsAlert2()
//            case .authorizedAlways, .authorizedWhenInUse:
//                let locationViewController = LocationMatchViewController()
//                locationViewController.user = user
//                let navigationController = UINavigationController(rootViewController: locationViewController)
//                present(navigationController, animated: true)
//            }
//        } else {
//            showSettingsAlert2()
//        }
//    }
//
//    private func showSettingsAlert2() {
//        let alert = UIAlertController(title: "Enable Location", message: "Crusht would like to use your location to match you with nearby users.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
//
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
//            return
//        })
//        present(alert, animated: true)
//    }
    
    
    @objc fileprivate func handleInfo() {
        let infoView = InfoView()
        infoView.infoText.text = "Crush Classmates: Select the heart next to people at your school/alma mater. If they select the heart on your name as well, you'll be matched in the chats tab!"
        tabBarController?.view.addSubview(infoView)
        infoView.peekButton.isHidden = true
        infoView.fillSuperview()
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
                        self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
                        self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
                        UIApplication.shared.applicationIconBadgeNumber = 1
                    }
                    if (diff.type == .removed) {
                    }
                }
        }
    }
    
       fileprivate func fetchCurrentUser() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                if err != nil {
                    let loginController = LoginViewController()
                    self.present(loginController, animated: true)
                    return
                }
                guard let dictionary = snapshot?.data() else {return}
                let user = User(dictionary: dictionary)

                
              //  if self.user == nil || !self.user!.hasSamePreferences(user: user) || self.schoolArray.isEmpty {
                self.user = user
                
                self.tableView.reloadData()
                self.fetchParties()
                }
            }
    
          fileprivate func fetchParties () {
                        
            //Firestore.firestore().collection("parties").w
            Firestore.firestore().collection("parties").whereField("guests", arrayContains: user?.phoneNumber ?? "").getDocuments(completion: { (snapshot, err) in
                          if let err = err {
                              print(err)
                              return
                          }
                          if snapshot?.isEmpty ?? true { return }
                          
                          snapshot?.documents.forEach({ (documentSnapshot) in
                              let partyDictionary = documentSnapshot.data()
                              let party = Party(dictionary: partyDictionary)
                              self.partiesArray.append(party)
                          })
                          
                          DispatchQueue.main.async {
                              self.partiesArray.sort { (party1, party2) in
                                  guard let partyName1 = party1.partyName else { return false }
                                  guard let partyName2 = party2.partyName else { return true }
                                  return partyName1 < partyName2
                              }
                              self.tableView.reloadData()
                          }
                      })
                  }
              
          
        

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PartyCell
          cell.selectionStyle = .none
          
          if !partiesArray.isEmpty {
              let party = isFiltering() ? parties[indexPath.row] : partiesArray[indexPath.row]
              cell.setup(party: party)
          } else {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  if self.partiesArray.isEmpty {
                      cell.profileImageView.image = nil
                      cell.textLabel?.text = "No Party Invites"
                      cell.textLabel?.adjustsFontSizeToFitWidth = true
                  }
              }
          }
          return cell
      }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 65.0
     }
     
     override func numberOfSections(in tableView: UITableView) -> Int {
         return 1
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if isFiltering() {
             return parties.count
         }
         
         if partiesArray.isEmpty == true {
             return 1
         }
         
         return partiesArray.count
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard partiesArray.count > 0 else { return }
        let party = isFiltering() ? parties[indexPath.row] : partiesArray[indexPath.row]
        guard let partyID = party.partyUID else { return }
        
        Firestore.firestore().collection("parties").document(partyID).getDocument(completion: { (snapshot, err) in
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else {return}
            
            let party = Party(dictionary: dictionary)
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let partyController = PartyPageController(collectionViewLayout: layout)
            partyController.party = party
            partyController.user = self.user
            let myBackButton = UIBarButtonItem()
            myBackButton.title = " "
            self.navigationItem.backBarButtonItem = myBackButton

            //userDetailsController.delegate = self
            self.navigationController?.pushViewController(partyController, animated: true)
        })
    }
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        parties = partiesArray.filter({( party : Party) -> Bool in
            return party.partyName!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension PartyListController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
