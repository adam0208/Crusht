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
import CoreLocation
import GooglePlaces
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging
//This Controller shows venues around a users location

class BarsTableView: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, SettingsControllerDelegate, LoginControllerDelegate, UITabBarControllerDelegate {
    
    var user: User?
    var barArray = [Place]()
    var venues = [Place]()

    let cellId = "cellId"
    
    let locationManager = CLLocationManager()
    
    var userLat = Double()
    var userLong = Double()
    
    let animationView = AnimationView()
    var placesClient: GMSPlacesClient!

    
    // MARK: Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.tabBarController?.tabBar.isTranslucent = false
         tabBarController?.view.addSubview(animationView)
        animationView.fillSuperview()
        self.tabBarController?.delegate = self
        placesClient = GMSPlacesClient.shared()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        searchController.searchBar.barStyle = .black
        navigationController?.isNavigationBarHidden = false
        tableView.register(VenueCell.self, forCellReuseIdentifier: cellId)
        navigationItem.title = "Join Venues"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        self.locationManager.requestAlwaysAuthorization()
        
        self.tableView.refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(reloadBars), for: .valueChanged)
            refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        let swipeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-swipe-right-gesture-30").withRenderingMode(.alwaysOriginal),  style: .plain, target: self, action: #selector(handleMatchByLocationBttnTapped))
        let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-30"), style: .plain, target: self, action: #selector(handleInfo))
        
        navigationItem.rightBarButtonItems = [swipeButton, infoButton]

        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Venues Near You"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        listenForMessages()
        messageBadge.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
       fetchCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
                self.animationView.removeFromSuperview()
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBar.prefersLargeTitles = true
        if UIApplication.shared.applicationIconBadgeNumber == 1 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
        }
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                showSettingsAlert2()
            case .authorizedAlways, .authorizedWhenInUse:
                print("locatoin cool")
            }
        } else {
            showSettingsAlert2()
        }
        
    }
    
    // MARK: - Logic
    
   @objc fileprivate func reloadBars() {
        self.barArray.removeAll()
        fetchCurrentUser()
        DispatchQueue.main.async {
                  self.tableView.refreshControl?.endRefreshing()
               }
    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleInfo() {
        let infoView = InfoView()
        infoView.infoText.text = "Crush People at Venues: Join a venue to see who else will be there. Select the heart next to people that you have a crush on. If they select the heart on your name as well, you'll be matched in the chats tab! (note: users will appear in the venue for 18 hours in case you miss your window to connect!)"
        tabBarController?.view.addSubview(infoView)
        infoView.peekButton.isHidden = true
        infoView.fillSuperview()
    }
    
    @objc func handleMessages() {
        let messageController = MessageController()
        messageBadge.removeFromSuperview()
        messageController.user = user
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
    }
    
    fileprivate func listenForMessages() {
        guard let toId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: toId).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = "!"
                    self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .red
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
            }
        }
    }
    
    @objc func handleSettings() {
        let settingsController = ViewController()
        //settingsController.delegate = self
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLat = locValue.latitude
        userLong = locValue.longitude
    }
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if err != nil {
                let loginController = LoginViewController()
                self.present(loginController, animated: true)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
           if self.user?.phoneNumber == ""{
                       let loginController = LoginViewController()
                       loginController.modalPresentationStyle = .fullScreen
                       self.present(loginController, animated: true)
                   }
                   else if self.user?.name == "" {
                       let namecontroller = EnterNameController()
                       namecontroller.modalPresentationStyle = .fullScreen
                       self.present(namecontroller, animated: true)
                   }
                   
                   else if self.user?.birthday == "" {
                       let namecontroller = BirthdayController()
                       namecontroller.modalPresentationStyle = .fullScreen
                       self.present(namecontroller, animated: true)
                   }
                   
                   else if self.user?.school == "" {
                       let namecontroller = EnterSchoolController()
                       namecontroller.modalPresentationStyle = .fullScreen
                       self.present(namecontroller, animated: true)
                   }
                   
                   else if self.user?.bio == "" {
                       let namecontroller = BioController()
                       namecontroller.modalPresentationStyle = .fullScreen
                       self.present(namecontroller, animated: true)
                   }
                   
                   else if self.user?.gender == "" {
                       let namecontroller = YourSexController()
                       namecontroller.modalPresentationStyle = .fullScreen
                       self.present(namecontroller, animated: true)
                   }
                   
                   else if self.user?.sexPref == "" {
                       let namecontroller = GenderController()
                       namecontroller.modalPresentationStyle = .fullScreen
                       self.present(namecontroller, animated: true)
                   }
            
                    else if self.user?.imageUrl1 == "" {
                                 let photoController = EnterPhotoController()
                                 photoController.modalPresentationStyle = .fullScreen
                                 self.present(photoController, animated: true)
                             }
                   
                   let timestamp = Int(Date().timeIntervalSince1970)
                   
                   if Int(truncating: self.user?.timeLastJoined ?? 5000) < timestamp - 64800 {
                       var docData = [String: Any]()
                       guard let uid = Auth.auth().currentUser?.uid else { return}
                       if self.user?.imageUrl1 != "" && self.user?.imageUrl2 != "" && self.user?.imageUrl3 != "" {
                           docData = [
                               "uid": uid,
                               "Full Name": self.user?.name ?? "",
                               "ImageUrl1": self.user?.imageUrl1 ?? "",
                               "ImageUrl2": self.user?.imageUrl2 ?? "",
                               "ImageUrl3": self.user?.imageUrl3 ?? "",
                               "Age": self.calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                               "Birthday": self.user?.birthday ?? "",
                               "School": self.user?.school ?? "",
                               "Bio": self.user?.bio ?? "",
                               "minSeekingAge": self.user?.minSeekingAge ?? 18,
                               "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                               "maxDistance": self.user?.maxDistance ?? 3,
                               "email": self.user?.email ?? "",
                               "fbid": self.user?.fbid ?? "",
                               "PhoneNumber": self.user?.phoneNumber ?? "",
                               "deviceID": Messaging.messaging().fcmToken ?? "",
                               "Gender-Preference": self.user?.sexPref ?? "",
                               "User-Gender": self.user?.gender ?? "",
                               "CurrentVenue": "",
                               "TimeLastJoined": timestamp - 3600
                           ]
                       } else if self.user?.imageUrl1 != "" && self.user?.imageUrl2 != "" && self.user?.imageUrl3 == "" {
                           docData = [
                               "uid": uid,
                               "Full Name": self.user?.name ?? "",
                               "ImageUrl1": self.user?.imageUrl1 ?? "",
                               "ImageUrl2": self.user?.imageUrl2 ?? "",
                               "Age": self.calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                               "Birthday": self.user?.birthday ?? "",
                               "School": self.user?.school ?? "",
                               "Bio": self.user?.bio ?? "",
                               "minSeekingAge": self.user?.minSeekingAge ?? 18,
                               "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                               "maxDistance": self.user?.maxDistance ?? 3,
                               "email": self.user?.email ?? "",
                               "fbid": self.user?.fbid ?? "",
                               "PhoneNumber": self.user?.phoneNumber ?? "",
                               "deviceID": Messaging.messaging().fcmToken ?? "",
                               "Gender-Preference": self.user?.sexPref ?? "",
                               "User-Gender": self.user?.gender ?? "",
                               "CurrentVenue": "",
                               "TimeLastJoined": timestamp - 3600
                           ]
                       }
                       else if self.user?.imageUrl1 != "" && self.user?.imageUrl2 == "" && self.user?.imageUrl3 == "" {
                           docData = [
                               "uid": uid,
                               "Full Name": self.user?.name ?? "",
                               "ImageUrl1": self.user?.imageUrl1 ?? "",
                               "Age": self.calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                               "Birthday": self.user?.birthday ?? "",
                               "School": self.user?.school ?? "",
                               "Bio": self.user?.bio ?? "",
                               "minSeekingAge": self.user?.minSeekingAge ?? 18,
                               "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                               "maxDistance": self.user?.maxDistance ?? 3,
                               "email": self.user?.email ?? "",
                               "fbid": self.user?.fbid ?? "",
                               "PhoneNumber": self.user?.phoneNumber ?? "",
                               "deviceID": Messaging.messaging().fcmToken ?? "",
                               "Gender-Preference": self.user?.sexPref ?? "",
                               "User-Gender": self.user?.gender ?? "",
                               "CurrentVenue": "",
                               "TimeLastJoined": timestamp - 3600
                           ]
                       }
                       Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                           if err != nil {
                               return
                           }
                       }
                   }

            
            let geoFirestoreRef = Firestore.firestore().collection("users")
            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
            
            geoFirestore.setLocation(location: CLLocation(latitude: self.userLat, longitude: self.userLong), forDocumentWithID: uid) { (error) in
                if (error != nil) {
                    print("An error occured", error!)
                } else {
                    print("Saved location successfully!")
                }
            }
            var currentLocation: CLLocation = CLLocation(latitude: self.userLat, longitude: self.userLong)
            var locationName : String = "bar"
            var searchRadius : Int = 5000
            self.fetchGoogleData(forLocation: currentLocation, locationName: locationName, searchRadius: searchRadius )
        }
   
    }
    
    //Places instead of geofirestore
    
        
    lazy var googleClient: GoogleClientRequest = GoogleClient()
     
            
    func fetchGoogleData(forLocation: CLLocation, locationName: String, searchRadius: Int) {
        print("hi")
      var currentLocation: CLLocation = CLLocation(latitude: self.userLat, longitude: self.userLong)
      var locationName : String = "bar"
    var searchRadius : Int = 2000
         googleClient.getGooglePlacesData(forKeyword: locationName, location: currentLocation, withinMeters: searchRadius) { (response) in
            print(response.results, "yo")
            self.fetchBars(places: response.results)
            
         
        }
    }
    
//    var barsDictionary = [String: [String]]()
//    var  barSectionTitles = [String]()
//    var bars = [String]()
        
    fileprivate func fetchBars(places: [Place]) {
        print("sup")
        for place in places {
        let name = place.name
        let address = place.address
        let location = ("lat: \(place.geometry.location.latitude), lng: \(place.geometry.location.longitude)")
           
            self.barArray.append(place)
              
            DispatchQueue.main.async {
        self.barArray.sort { (bar1, bar2) in
             let venueName1 = bar1.name
             let venueName2 = bar2.name
            return venueName1 < venueName2
        }
//                for bar in self.barArray {
//                    let barKey = String(bar.name.prefix(1))
//                    if var barValues = self.barsDictionary[barKey] {
//                        barValues.append(bar.name)
//                        self.barsDictionary[barKey] = barValues
//                         } else {
//                        self.barsDictionary[barKey] = [bar.name]
//                         }
//                 }
//                self.barSectionTitles = [String](self.barsDictionary.keys)
//                self.barSectionTitles = self.barSectionTitles.sorted(by: { $0 < $1 })
                self.tableView.reloadData()
            }
        }
    }
        
    
    
    
//    fileprivate func fetchBars () {
//        let geoFirestoreRef = Firestore.firestore().collection("venues")
//        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
//        let userCenter = CLLocation(latitude: userLat, longitude: userLong)
//        let radiusQuery = geoFirestore.query(withCenter: userCenter, radius: 20)
//
//        let _ = radiusQuery.observe(.documentEntered) { (key, location) in
//            if let key = key, location != nil {
//                Firestore.firestore().collection("venues").whereField("venueName", isEqualTo: key).order(by: "name").getDocuments(completion: { (snapshot, err) in
//                    if let err = err {
//                        print(err)
//                        return
//                    }
//                    if snapshot?.isEmpty ?? true { return }
//
//                    snapshot?.documents.forEach({ (documentSnapshot) in
//                        let barDictionary = documentSnapshot.data()
//                        let bar = Venue(dictionary: barDictionary)
//                        self.barArray.append(bar)
//                    })
//
//                    DispatchQueue.main.async {
//                        self.barArray.sort { (bar1, bar2) in
//                            guard let venueName1 = bar1.venueName else { return false }
//                            guard let venueName2 = bar2.venueName else { return true }
//                            return venueName1 < venueName2
//                        }
//                        self.tableView.reloadData()
//                    }
//                })
//            }
//        }
//    }
    
    var peekBarName = String()
    
    private func handleJoin(barName: String) {
        let timestamp = Int(Date().timeIntervalSince1970)
        peekBarName = barName
        if user?.currentVenue == barName {
            let userbarController = UsersInBarTableView()
            userbarController.barName = barName
            userbarController.user = user
            userbarController.verb = "(Joined)"
            let myBackButton = UIBarButtonItem()
            myBackButton.title = " "
            self.navigationItem.backBarButtonItem = myBackButton
            self.navigationController?.pushViewController(userbarController, animated: true)
        }
            
        else if Int(truncating: user?.timeLastJoined ?? 5000) < timestamp - 1800 {
            let alert = UIAlertController(title: "Join Venue?", message: "Join \(barName) to see who's there?", preferredStyle: .alert)
            let action = UIAlertAction(title: "Join", style: .default) { _ in
                var docData = [String: Any]()
                guard let uid = Auth.auth().currentUser?.uid else {return}
                if self.user?.imageUrl1 != "" && self.user?.imageUrl2 != "" && self.user?.imageUrl3 != "" {
                    docData = [
                        "uid": uid,
                        "Full Name": self.user?.name ?? "",
                        "ImageUrl1": self.user?.imageUrl1 ?? "",
                        "ImageUrl2": self.user?.imageUrl2 ?? "",
                        "ImageUrl3": self.user?.imageUrl3 ?? "",
                        "Age": self.calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                        "Birthday": self.user?.birthday ?? "",
                        "School": self.user?.school ?? "",
                        "Bio": self.user?.bio ?? "",
                        "minSeekingAge": self.user?.minSeekingAge ?? 18,
                        "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                        "maxDistance": self.user?.maxDistance ?? 3,
                        
                        "PhoneNumber": self.user?.phoneNumber ?? "",
                        "deviceID": Messaging.messaging().fcmToken ?? "",
                        "Gender-Preference": self.user?.sexPref ?? "",
                        "User-Gender": self.user?.gender ?? "",
                        "CurrentVenue": barName,
                        "TimeLastJoined": timestamp
                    ]
                } else if self.user?.imageUrl1 != "" && self.user?.imageUrl2 != "" && self.user?.imageUrl3 == "" {
                    docData = [
                        "uid": uid,
                        "Full Name": self.user?.name ?? "",
                        "ImageUrl1": self.user?.imageUrl1 ?? "",
                        "ImageUrl2": self.user?.imageUrl2 ?? "",
                        "Age": self.calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                        "Birthday": self.user?.birthday ?? "",
                        "School": self.user?.school ?? "",
                        "Bio": self.user?.bio ?? "",
                        "minSeekingAge": self.user?.minSeekingAge ?? 18,
                        "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                        "maxDistance": self.user?.maxDistance ?? 3,
                        
                        "PhoneNumber": self.user?.phoneNumber ?? "",
                        "deviceID": Messaging.messaging().fcmToken ?? "",
                        "Gender-Preference": self.user?.sexPref ?? "",
                        "User-Gender": self.user?.gender ?? "",
                        "CurrentVenue": barName,
                        "TimeLastJoined": timestamp
                    ]
                }
                else if self.user?.imageUrl1 != "" && self.user?.imageUrl2 == "" && self.user?.imageUrl3 == "" {
                    docData = [
                        "uid": uid,
                        "Full Name": self.user?.name ?? "",
                        "ImageUrl1": self.user?.imageUrl1 ?? "",
                        "Age": self.calcAge(birthday: self.user?.birthday ?? "10-31-1995"),
                        "Birthday": self.user?.birthday ?? "",
                        "School": self.user?.school ?? "",
                        "Bio": self.user?.bio ?? "",
                        "minSeekingAge": self.user?.minSeekingAge ?? 18,
                        "maxSeekingAge": self.user?.maxSeekingAge ?? 50,
                        "maxDistance": self.user?.maxDistance ?? 3,
                        
                        "PhoneNumber": self.user?.phoneNumber ?? "",
                        "deviceID": Messaging.messaging().fcmToken ?? "",
                        "Gender-Preference": self.user?.sexPref ?? "",
                        "User-Gender": self.user?.gender ?? "",
                        "CurrentVenue": barName,
                        "TimeLastJoined": timestamp
                        
                    ]
                }
                Firestore.firestore().collection("users").document(uid).setData(docData)
                
                let userbarController = UsersInBarTableView()
                userbarController.barName = barName
                userbarController.user = self.user
                userbarController.verb = "(Joined)"
                
                let myBackButton = UIBarButtonItem()
                myBackButton.title = " "
                self.navigationItem.backBarButtonItem = myBackButton
                self.navigationController?.pushViewController(userbarController, animated: true)
            }
            let cancel = UIAlertAction(title: "Don't Join", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            let infoView = InfoView()
            infoView.infoText.text = "You can only join one venue every 30 minutes, but you can peek to see who's there."
            tabBarController?.view.addSubview(infoView)
            infoView.peekButton.addTarget(self, action: #selector(handlePeek), for: .touchUpInside)
            infoView.fillSuperview()
            return
        }
    }
    
    @objc fileprivate func handlePeek() {
        
        let peekController = UsersInBarTableView()
        peekController.barName = peekBarName
        peekController.user = self.user
        peekController.verb = "(Peeking)"
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        self.navigationItem.backBarButtonItem = myBackButton
        self.navigationController?.pushViewController(peekController, animated: true)
    }

    
    
    private func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
        let age = calcAge.year
        return age!
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! VenueCell
        cell.selectionStyle = .none
        
        if !barArray.isEmpty {
            let venue = isFiltering() ? venues[indexPath.row] : barArray[indexPath.row]
            cell.setup(place: venue)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.barArray.isEmpty {
                    cell.profileImageView.image = nil
                    cell.textLabel?.text = "Coming to your area soon!"
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard barArray.count > 0 else { return }
        let venue = isFiltering() ? venues[indexPath.row] : barArray[indexPath.row]

        Firestore.firestore().collection("venues").document(venue.id).getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            if snapshot!.exists {
                self.handleJoin(barName: venue.name ?? "Venue")
            }
            else {
                let docData: [String: Any] =
                    ["name": venue.name,
                     "id": venue.id
                    ]
                Firestore.firestore().collection("venues").document(venue.id).setData(docData) { (err) in
                    if let err = err {
                        return
                    }
                     self.handleJoin(barName: venue.name ?? "Venue")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return venues.count
        }

        if barArray.isEmpty == true {
            return 1
        }

        return barArray.count
    }
    
//     override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//
//        return barSectionTitles
//
//    }
    
    // MARK: - UISearchBar
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        venues = barArray.filter({( venue : Place) -> Bool in
            return venue.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - SettingsControllerDelegate
    func didSaveSettings() {
        barArray.removeAll()
        fetchCurrentUser()
    }
    
    // MARK: - LoginControllerDelegate
    
    func didFinishLoggingIn() {
        barArray.removeAll()
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
    
    // MARK: - User Interface
    
    let messageBadge: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 5, width: 10, height: 10))
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
}

extension BarsTableView: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
