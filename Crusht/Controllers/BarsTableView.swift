//
//  BarsTableView.swift
//  Crusht
//
//  Created by William Kelly on 4/20/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import JGProgressHUD
import CoreLocation
import SDWebImage

class BarsTableView: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, SettingsControllerDelegate, LoginControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    var user: User?
    
    var barArray = [Venue]()
    
    let locationManager = CLLocationManager()
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
searchController.searchBar.barStyle = .black
        navigationController?.isNavigationBarHidden = false
        tableView.register(VenueCell.self, forCellReuseIdentifier: cellId)
        navigationItem.title = "Select to Check Venue"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            print(locationManager.location?.coordinate.latitude as Any)
            print(locationManager.location?.coordinate.latitude as Any)
            print("We have your location!")
        }
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        let messageButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-communication-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMessages))
        let swipeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
        navigationItem.rightBarButtonItems = [messageButton, swipeButton]

        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Venues Near You"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        navigationController?.navigationBar.addSubview(messageBadge)
        messageBadge.anchor(top: navigationController?.navigationBar.topAnchor, leading: nil, bottom: navigationController?.navigationBar.bottomAnchor, trailing: navigationController?.navigationBar.trailingAnchor)
        listenForMessages()
        messageBadge.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        fetchCurrentUser()
    }
    
    @objc func handleMessages() {
        let messageController = MessageController()
        messageBadge.removeFromSuperview()
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
        //navigationController?.pushViewController(messageController, animated: true)
        
    }
    
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
                        self.messageBadge.isHidden = false
                        
                    }
                    if (diff.type == .removed) {
                    }
                }
        }
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        settingsController.user = user
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
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        userLat = locValue.latitude
        userLong = locValue.longitude
    }
    
    var userLat = Double()
    var userLong = Double()
    
   
        
    fileprivate func fetchCurrentUser() {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                guard let dictionary = snapshot?.data() else {return}
                self.user = User(dictionary: dictionary)
                
                print(self.user?.phoneNumber ?? "Fuck you")
                self.fetchBars()
        }
    }
    
    
    // MARK: - Table view data source
    
    let hud = JGProgressHUD(style: .dark)
    
    fileprivate func fetchBars () {
        
        hud.textLabel.text = "Fetching bars, hold tight :)"
        hud.show(in: view)
        hud.dismiss(afterDelay: 1)
        
        let geoFirestoreRef = Firestore.firestore().collection("venues")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        let userCenter = CLLocation(latitude: userLat, longitude: userLong)
        
        let radiusQuery = geoFirestore.query(withCenter: userCenter, radius: 20)
        
        print("hahahaaha")
        
        print(userLat, "Fuck")
        
        radiusQuery.observe(.documentEntered) { (key, location) in
            if let key = key, let loc = location {
                Firestore.firestore().collection("venues").whereField("venueName", isEqualTo: key).getDocuments(completion: { (snapshot, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    print(key, "hagaha")
                    
                    if (snapshot?.isEmpty)! {
                        self.hud.textLabel.text = "No bars listed in your area"
                        self.hud.show(in: self.view)
                        self.hud.dismiss(afterDelay: 2)
                        return
                    }
                    snapshot?.documents.forEach({ (documentSnapshot) in
                        let barDictionary = documentSnapshot.data()
                        let bar = Venue(dictionary: barDictionary)
                        print(bar.venueName!)
                        self.barArray.append(bar)
                        
                    })
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        
                    })
                })
                
            }
            
        }
    }
    
    
    
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! VenueCell
        
        
        if isFiltering() {
            let venue = venues[indexPath.row]
            cell.textLabel?.text = venue.venueName
            let imageUrl = venue.venuePhotoUrl!
            let url = URL(string: imageUrl)
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                cell.profileImageView.image = image
            }
        } else {
            let venue = barArray[indexPath.row]
            cell.textLabel?.text = venue.venueName
            let imageUrl = venue.venuePhotoUrl!
            let url = URL(string: imageUrl)
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                cell.profileImageView.image = image
            }
        }
        
        //        if hasFavorited == true {
        //        cellL.starButton.tintColor = .red
        //        }
        //        else {
        //            cellL.starButton.tintColor = .gray
        //        }
        
        
        
        return cell
    }
    
    var venues = [Venue]()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = barArray[indexPath.row]
        let alert = UIAlertController(title: "Join Bar?", message: "Join \(venue.venueName ?? "this bar") to see who's there?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Join", style: .default){(UIAlertAction) in
            
            self.handleJoin(barName: venue.venueName ?? "Venue")
        }
        let cancel = UIAlertAction(title: "Don't Join", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return
      
    }
    
    fileprivate func handleJoin(barName: String) {
        
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        if Int(truncating: user?.timeLastJoined ?? 1000000) < timestamp - 1800 {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = [
                "uid": uid,
                "Full Name": user?.name ?? "",
                "ImageUrl1": user?.imageUrl1 ?? "",
                "ImageUrl2": user?.imageUrl2 ?? "",
                "ImageUrl3": user?.imageUrl3 ?? "",
                "Age": calcAge(birthday: user?.birthday ?? "10-31-1995"),
                "Birthday": user?.birthday ?? "",
                "School": user?.school ?? "",
                "Bio": user?.bio ?? "",
                "minSeekingAge": user?.minSeekingAge ?? 18,
                "maxSeekingAge": user?.maxSeekingAge ?? 50,
                "maxDistance": user?.maxDistance ?? 3,
                "email": user?.email ?? "",
                "fbid": user?.fbid ?? "",
                "PhoneNumber": user?.phoneNumber ?? "",
                "deviceID": Messaging.messaging().fcmToken ?? "",
                "Gender-Preference": user?.sexPref ?? "",
                "User-Gender": user?.gender ?? "",
                "CurrentVenue": barName,
                "TimeLastJoined": timestamp
            ]
            Firestore.firestore().collection("users").document(uid).setData(docData)
            
            
            let userbarController = UsersInBarTableView()
            userbarController.barName = barName
            userbarController.user = self.user
            
            let myBackButton = UIBarButtonItem()
            myBackButton.title = " "
            self.navigationItem.backBarButtonItem = myBackButton
            
            self.navigationController?.pushViewController(userbarController, animated: true)
        } else {
            hud.textLabel.text = "You can only join one venue every half-hour"
            hud.show(in: view)
            hud.dismiss(afterDelay: 2)
            return
        }
        
    }
    
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
        let age = calcAge.year
        return age!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return venues.count
        }
        
        return barArray.count
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        venues = barArray.filter({( venue : Venue) -> Bool in
            return venue.venueName!.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension BarsTableView: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
