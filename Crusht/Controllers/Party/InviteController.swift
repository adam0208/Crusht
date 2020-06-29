//
//  InviteController.swift
//  Crusht
//
//  Created by William Kelly on 2/17/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import FirebaseAuth
import FirebaseFirestore

class InviteController: UITableViewController, UISearchBarDelegate, UITabBarControllerDelegate {
    //Flat out redo this shit
    //Plug in COntacts string manipulation
    
   var expandableContacts = ExpandableContacts(isExpanded: true, contacts: [])
        lazy var filteredExpandableContacts = ExpandableContacts(isExpanded: true, contacts: [])
         var party: Party?
        var users = [User]()
        var user: User?
    
        var partyTitle = String()
        var partyUID = String()
        var location = String()

        private var crushScore: CrushScore?
        var crushScoreID = String()

        var phoneFinal = String()
        var showIndexPaths = false
    var swipes = [String]()

        let messageController = MessageController()
        let searchController = UISearchController(searchResultsController: nil)

        let cellId = "cellId123123"

        // MARK: - Life Cycle Methods

        override func viewDidLoad() {
             super.viewDidLoad()
             self.tabBarController?.delegate = self
            self.tabBarController?.tabBar.isTranslucent = false

             navigationController?.navigationBar.prefersLargeTitles = true
             navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-back-filled-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))

             // Setup the Search Controller
             view.addSubview(searchController.searchBar)
             searchController.searchResultsUpdater = self
             searchController.obscuresBackgroundDuringPresentation = false
             searchController.searchBar.placeholder = "Search Contacts"
             searchController.searchBar.barStyle = .black
             searchController.searchBar.tintColor = .white
             navigationItem.searchController = self.searchController
             definesPresentationContext = true
             navigationController?.isNavigationBarHidden = false

             messageBadge.isHidden = true

             navigationController?.navigationBar.isTranslucent = false
             navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)

             // Setup the Scope Bar
             self.searchController.searchBar.delegate = self
             self.navigationItem.hidesSearchBarWhenScrolling = false
             navigationItem.title = "Invite Contacts"
             tableView.register(InviteContactsCell.self, forCellReuseIdentifier: cellId)
             tableView.reloadData()
         }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            navigationController?.navigationBar.prefersLargeTitles = true
            tabBarController?.tabBar.isHidden = false
            fetchCurrentUser()

            tableView.reloadData()
        }

        // MARK: - Logic
    

    
    @objc fileprivate func handleDone() {
        let customtabController = CustomTabBarController()
        customtabController.modalPresentationStyle = .fullScreen
        self.present(customtabController, animated: true)
        
    }

        fileprivate func handleContacts() {
            let store = CNContactStore()
            switch CNContactStore.authorizationStatus(for: .contacts) {

            case .authorized:
                fetchCurrentUser()
            case .denied:
                showSettingsAlert()
            case .restricted, .notDetermined:
                store.requestAccess(for: .contacts) { granted, error in
                    if granted {
                        self.fetchCurrentUser()
                    } else {
                        DispatchQueue.main.async {
                            self.showSettingsAlert()
                        }
                    }
                }
            }
        }

        private func showSettingsAlert() {
            let alert = UIAlertController(title: "Enable Contacts", message: "Crusht requires access to Contacts to proceed. WE DON'T STORE YOUR CONTACTS IN OUR DATABASE. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in

                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                return
            })
            present(alert, animated: true)
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

                self.fetchContacts()
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

        // You should use Custom Delegation properly instead
        func someMethodIWantToCall(cell: UITableViewCell) {
            guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
            let contact = isFiltering() ? filteredExpandableContacts.contacts[indexPathTapped.row] : expandableContacts.contacts[indexPathTapped.row]
            print("hi, i h8 myself")
           // if cell.accessoryView?.tintColor != .red {
                handleInite(contact: contact, cell: cell)
            //}
        }

        fileprivate func fetchContacts() {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, err) in
                if err != nil {
                    return
                }

                if granted {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

                    request.sortOrder = CNContactSortOrder.givenName

                    do {
                        var favoritableContacts = [FavoritableContact]()
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                            favoritableContacts.append(FavoritableContact(contact: contact, hasFavorited: false))
                        })

                        self.expandableContacts = ExpandableContacts(isExpanded: true, contacts: favoritableContacts)

                        self.fetchInvites()

                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })

                    } catch { }
                } else {
                    print("Access denied..")
                }
            }
        }

//        func saveInviteLocally(contact: FavoritableContact) {
//            swipes[contact.phoneCell] = didLike
//        }

        func saveInviteToFirestore(contact: FavoritableContact) {
            //let phoneNumber = user?.phoneNumber ?? ""
            
            let phoneString = contact.phoneCell
            let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
            let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
            let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
            let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
            let cardUID = phoneNoDash
            
            let twilioPhoneData: [String: Any] = ["phoneToInvite": cardUID,
                                                  "partyName": partyTitle,
                                                  "hostName": user?.name ?? ""
            ]
     //       let documentData = ["guests": [cardUID] FieldValue.arrayUnion(["greater_virginia"]]
            
            Firestore.firestore().collection("parties").document(partyUID).updateData(([
                "guests": FieldValue.arrayUnion([cardUID])
            ]))
            
            Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: cardUID).getDocuments { (snapshot, err) in
                if let err = err {
                    return
                }
                if snapshot!.isEmpty {
                    Firestore.firestore().collection("twilio-invites").document().setData(twilioPhoneData)
                }
                else {
                    Firestore.firestore().collection("parties").document(self.partyUID).updateData(([
                                 "guests": FieldValue.arrayUnion([cardUID])
                             ]))
                }
            }
            
       
      
    }
    
    fileprivate func fetchInvites() {
        Firestore.firestore().collection("parties").document(partyUID).getDocument { (snapshot, err) in
            if err != nil {
                
            }
            guard let dictionary = snapshot?.data() else {return}
            let party = Party(dictionary: dictionary)
            
            self.swipes = party.guestPhoneNumbers as! [String]
              DispatchQueue.main.async(execute: {
                                     self.tableView.reloadData()
                                 })

        }
    }


        func handleInite(contact: FavoritableContact, cell: UITableViewCell) {
            //saveInviteLocally(contact: contact)
            saveInviteToFirestore(contact: contact)
            cell.accessoryView?.tintColor = .red
        }

        @objc fileprivate func handleBack() {
            dismiss(animated: true)
        }

        // MARK: - Table view data source

        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 36
        }

        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 65.0
        }

        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return isFiltering() ? filteredExpandableContacts.contacts.count : expandableContacts.contacts.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let favoritableContact = isFiltering() ? filteredExpandableContacts.contacts[indexPath.row] : expandableContacts.contacts[indexPath.row]
            let hasLiked = swipes.contains(favoritableContact.phoneCell)
            let cell = InviteContactsCell(style: .subtitle, reuseIdentifier: cellId)
            cell.setup(favoritableContact: favoritableContact, hasLiked: hasLiked)
            cell.link = self
            return cell
        }

        // MARK: - LoginControllerDelegate

      

        // MARK: - UITabBarControllerDelegate

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            let tabBarIndex = tabBarController.selectedIndex
            if tabBarIndex == 3 {
                self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
                self.tabBarController?.viewControllers?[3].tabBarItem.badgeColor = .clear
            }
        }

        // MARK: - SettingsControllerDelegate

       

        // MARK: - UISearchBar

        func searchBarIsEmpty() -> Bool {
            return searchController.searchBar.text?.isEmpty ?? true
        }

        func filterContentForSearchText(_ searchText: String, scope: String = "All") {
            filteredExpandableContacts = expandableContacts.filterBy(text: searchText)
            tableView.reloadData()
        }

        func isFiltering() -> Bool {
            return searchController.isActive && !searchBarIsEmpty()
        }

        // MARK: - User Interface

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
    }

    // MARK: - UISearchResultsUpdating
    extension InviteController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
