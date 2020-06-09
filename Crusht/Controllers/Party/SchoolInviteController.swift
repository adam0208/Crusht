//
//  SchoolInviteController.swift
//  Crusht
//
//  Created by William Kelly on 2/25/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class SchoolInviteController: UITableViewController, UISearchBarDelegate, UITabBarControllerDelegate {
    
    var fetchedAllUsers = false
    var fetchingMoreUsers = false
    var lastFetchedDocument: QueryDocumentSnapshot? = nil
    
    var party: Party?
           var users = [User]()
           var user: User?
       
           var partyTitle = String()
           var partyUID = String()
           var location = String()

    
  
    let messageController = MessageController()
    var schoolDelegate: SchoolDelegate?
    
    private var crushScore: CrushScore?
    var hasFavorited = Bool()
    var locationSwipes = [String: Int]()
    var blocks = [String: Int]()
    var sawMessage = Bool()
    var isRightSex = Bool()
    var crushScoreID = String()
    var matchUID = String()

    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    
    var schoolArray = [User]()
    var schoolUserDictionary = [String: User]()
    var swipes = [String]()
    
    // MARK: - Life Cycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBar.prefersLargeTitles = true
        
        fetchCurrentUser()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        
        
        tableView.register(InviteSchoolCell.self, forCellReuseIdentifier: cellId)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCellId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
            
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-back-filled-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))
        
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
        
        //refresh controll
        self.tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadSchool), for: .valueChanged)
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
    
    // MARK: - Logic
    

    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleDone() {
          let customtabController = CustomTabBarController()
          customtabController.modalPresentationStyle = .fullScreen
          self.present(customtabController, animated: true)
          
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
                
    //            if user.phoneNumber == ""{
    //                let loginController = LoginViewController()
    //                self.present(loginController, animated: true)
    //                return
    //
    //            }
    //            else if user.name == "" {
    //                let namecontroller = EnterNameController()
    //                namecontroller.phone = self.user?.phoneNumber ?? ""
    //                self.present(namecontroller, animated: true)
    //                return
    //
    //            }
                
                if self.user == nil || !self.user!.hasSamePreferences(user: user) || self.schoolArray.isEmpty {
                    self.user = user
                    self.fetchedAllUsers = false
                    self.lastFetchedDocument = nil
                    self.schoolArray.removeAll()
                    self.tableView.reloadData()
                    //self.fetchSwipes()
                    self.fetchInvites()
               
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
             
            self.fetchSchoolUsers()

          }
      }
    
    @objc fileprivate func reloadSchool () {

        fetchCurrentUser()
        DispatchQueue.main.async {
             self.tableView.refreshControl?.endRefreshing()
          }
    }
 
    fileprivate func fetchSchoolUsers() {
        print("hi hi")
        guard !fetchedAllUsers, !fetchingMoreUsers else { return }
        fetchingMoreUsers = true
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        
        let school = user?.school ?? "Your School"
        navigationItem.title = school
        var query: Query
        if let lastFetchedDocument = lastFetchedDocument {
            query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school).order(by: "Full Name").start(afterDocument: lastFetchedDocument).limit(to: 15)
        } else {
            query = Firestore.firestore().collection("users").whereField("School", isEqualTo: school).order(by: "Full Name").limit(to: 15)
        }
        
        // Change logic where gender variable is just the where field firebase thing
        query.getDocuments { (snapshot, err) in
            guard err == nil, let snapshot = snapshot else { return }
            
            if snapshot.documents.count == 0 {
                self.fetchedAllUsers = true
                self.fetchingMoreUsers = false
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                return
            }
            
            self.lastFetchedDocument = snapshot.documents.last
            snapshot.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let crush = User(dictionary: userDictionary)
                let isNotCurrentUser = crush.uid != Auth.auth().currentUser?.uid
                let hasBlocked = self.blocks[crush.uid ?? ""] == nil
                
                let sexPref = self.user?.sexPref
                if sexPref == "Female" {
                    self.isRightSex = crush.gender == "Female" || crush.gender == "Other"
                }
                else if sexPref == "Male" {
                    self.isRightSex = crush.gender == "Male" || crush.gender == "Other"
                }
                else {
                    self.isRightSex = crush.school == self.user?.school
                }
                
                let maxAge = crush.age ?? 18 < ((self.user?.age)! + 5)
                let minAge = crush.age ?? 18 > ((self.user?.age)! - 5)
                
                if hasBlocked && isNotCurrentUser && minAge && maxAge && self.isRightSex {
                    self.schoolArray.append(crush)
                }
            })
            DispatchQueue.main.async(execute: {
                self.fetchingMoreUsers = false
                self.tableView.reloadData()
            })
        }
        
    }
    func saveInviteToFirestore(crush: User) {
               // let phoneNumber = user?.phoneNumber ?? ""
        let cardUID = crush.phoneNumber
                let twilioPhoneData: [String: Any] = ["phoneToInvite": cardUID,
                                                      "partyName": partyTitle,
                                                      "hostName": user?.name ?? ""
                ]
         //       let documentData = ["guests": [cardUID] FieldValue.arrayUnion(["greater_virginia"]]
                
                Firestore.firestore().collection("parties").document(partyUID).updateData(([
                    "guests": FieldValue.arrayUnion([cardUID ?? ""])
                ]))
                
    //            Firestore.firestore().collection("users").whereField("PhoneNumber", isEqualTo: cardUID).getDocuments { (snapshot, err) in
    //                if let err = err {
    //                    return
    //                }
    //                if snapshot!.isEmpty {
    //                    Firestore.firestore().collection("twilio-invites").document().setData(twilioPhoneData)
    //                }
    //            }
                
           
          
        }
    
    func handleInite(crush: User, cell: UITableViewCell) {
        //saveInviteLocally(contact: contact)
        saveInviteToFirestore(crush: crush)
        cell.accessoryView?.tintColor = .red
    }


    func hasTappedCrush(cell: UITableViewCell) {
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        let crush = isFiltering() ? users[indexPathTapped.row] : schoolArray[indexPathTapped.row]
        crushScoreID = crush.uid ?? ""
        
        let phoneString = crush.phoneNumber ?? ""
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        
        matchUID = phoneNoDash
        
        if cell.accessoryView?.tintColor == #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1) {
            handleInite(crush: crush, cell: cell)
        }
        else {
        }
    }
    
   
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isFiltering() {
                return users.count
            }
            if schoolArray.isEmpty {
                return 1
            }
            return schoolArray.count
            
        } else if section == 1 && fetchingMoreUsers {
            return 1
        }
        
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if schoolArray.count > 0 && indexPath.section == 0 && indexPath.row >= schoolArray.count - 3 && !isFiltering() {
            fetchSchoolUsers()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! InviteSchoolCell
            cell.link = self
            if !schoolArray.isEmpty {
                let crush = isFiltering() ? users[indexPath.row] : schoolArray[indexPath.row]
                let hasLiked = swipes.contains(crush.phoneNumber ?? "")
                let swipeLike = locationSwipes[crush.uid ?? ""] == 1
                hasFavorited = hasLiked || swipeLike
                cell.setup(crush: crush, hasFavorited: hasFavorited)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.schoolArray.isEmpty {
                        cell.profileImageView.image = nil
                        cell.textLabel?.text = "No classmates to show 😔"
                        cell.accessoryView?.isHidden = true
                    }
                }
            }
            return cell
        } else { // Set up loading cell
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: loadingCellId, for: indexPath) as! LoadingCell
            loadingCell.spinner.startAnimating()
            return loadingCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard schoolArray.count > 0 else { return }
        let crush = isFiltering() ? users[indexPath.row] : schoolArray[indexPath.row]
        guard let profUID = crush.uid else { return }
        
        Firestore.firestore().collection("users").document(profUID).getDocument(completion: { (snapshot, err) in
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else {return}
            
            var user = User(dictionary: dictionary)
            user.uid = profUID
            let userDetailsController = UserDetailsController()
            
            let myBackButton = UIBarButtonItem()
            myBackButton.title = " "
            self.navigationItem.backBarButtonItem = myBackButton
            
            userDetailsController.cardViewModel = user.toCardViewModel()
            //userDetailsController.delegate = self
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        })
    }
    
    // MARK: - UISearchBar
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        users = schoolArray.filter({( user : User) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    

    // MARK: - SettingsControllerDelegate

    // MARK: - LoginControllerDelegate

   
    
    // MARK: - UITabBarControllerDelegate
    

    // MARK: - User Interface
    
}

extension SchoolInviteController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
