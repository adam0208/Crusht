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

class BarsTableView: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    var user: User?
    
    var barArray = [Venue]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        tableView.register(VenueCell.self, forCellReuseIdentifier: cellId)
        navigationItem.title = "Select to Check Venue"
        
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
        
        view.addSubview(searchController.searchBar)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Venues Near You"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        
        self.searchController.searchBar.delegate = self
        self.navigationItem.hidesSearchBarWhenScrolling = false
        fetchCurrentUser()
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
        
        
        self.fetchBars()
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
            if let profileImageUrl = venue.venuePhotoUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        } else {
            let venue = barArray[indexPath.row]
            cell.textLabel?.text = venue.venueName
            if let profileImageUrl = venue.venuePhotoUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
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
        let userbarController = UsersInBarTableView()
        userbarController.barName = venue.venueName ?? ""
        userbarController.user = user
        let myBackButton = UIBarButtonItem()
        myBackButton.title = "👈"
        navigationItem.backBarButtonItem = myBackButton
        navigationController?.pushViewController(userbarController, animated: true)
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
        return 60.0
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
