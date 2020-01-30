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

class PartyListController: UITableViewController, SettingsControllerDelegate {
    func didSaveSettings() {
        partiesArray.removeAll()
        fetchCurrentUser()
    }
    
    
    let cellId = "cellId"
    var user: User?
    var partiesArray = [Venue]()
    
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
                
                tableView.register(VenueCell.self, forCellReuseIdentifier: cellId)

                let swipeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
                let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-30"), style: .plain, target: self, action: #selector(handleInfo))
                
                listenForMessages()
                navigationItem.rightBarButtonItems = [swipeButton, infoButton]
                
                // Setup the Search Controller
                //view.addSubview(searchController.searchBar)
        //        searchController.searchResultsUpdater = self
        //        searchController.obscuresBackgroundDuringPresentation = false
        //        searchController.searchBar.placeholder = "Search School"
               // navigationItem.searchController = self.searchController
                definesPresentationContext = true
                   
                // Setup the Scope Bar
        //        self.searchController.searchBar.delegate = self
        //        self.navigationItem.hidesSearchBarWhenScrolling = false
                messageBadge.isHidden = true
                
                //refresh controll
                self.tableView.refreshControl = UIRefreshControl()
                refreshControl?.addTarget(self, action: #selector(reloadParty), for: .valueChanged)
                refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
                let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)]
                let attributedTitle = NSAttributedString(string: "Reloading", attributes: attributes)
                refreshControl?.attributedTitle = attributedTitle
                

                // Setup the search footer
                navigationController?.navigationBar.isTranslucent = false
                navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
                //searchController.searchBar.barStyle = .black
                navigationController?.navigationBar.prefersLargeTitles = true
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            

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
                    //self.fetchSwipes()
                   // self.fetchSchoolUsers()
                //    self.fetchBlocks()
                }
            }
    
          fileprivate func fetchBars () {
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
              
            Firestore.firestore().collection("users").document(uid).collection("parties").getDocuments(completion: { (snapshot, err) in
                          if let err = err {
                              print(err)
                              return
                          }
                          if snapshot?.isEmpty ?? true { return }
                          
                          snapshot?.documents.forEach({ (documentSnapshot) in
                              let barDictionary = documentSnapshot.data()
                              let bar = Venue(dictionary: barDictionary)
                              self.partiesArray.append(bar)
                          })
                          
                          DispatchQueue.main.async {
                              self.partiesArray.sort { (bar1, bar2) in
                                  guard let venueName1 = bar1.venueName else { return false }
                                  guard let venueName2 = bar2.venueName else { return true }
                                  return venueName1 < venueName2
                              }
                              self.tableView.reloadData()
                          }
                      })
                  }
              
          
        

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
