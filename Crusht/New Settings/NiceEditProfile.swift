//
//  NiceEditProfile.swift
//  Crusht
//
//  Created by William Kelly on 6/12/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CustomImagePickerController: UIImagePickerController  {
    var imageBttn: UIButton?
}

class NiceEditProfile: UIViewController, SettingsControllerDelegate {
    func didSaveSettings() {
        
        fetchCurrentUser()
    }
    
private let reuseIdentifier = "NiceEditProfileCell"
    
       override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    var delegate: SettingsControllerDelegate?
    var photoView: PhotoView!
    var madeChanges = false
    var tableView: UITableView!
    
    var user: User?
    
    // MARK: - Init
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.didSaveSettings()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Helper Functions
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NiceEditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 800)
        
        loadPhotos()
    }
    
    fileprivate func loadPhotos() {
           let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 140)
           
           photoView = PhotoView(frame: frame)
        
           if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
                          
                        //  Nuke.loadImage(with: url, into: self.image1Button)
                          SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                             self.photoView.image1.image = image
                          }
                      }
           if let imageUrl2 = user?.imageUrl2, let url = URL(string: imageUrl2) {
                //  Nuke.loadImage(with: url, into: self.image1Button)
                    SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                        self.photoView.image2.image = image
                    }
                }
           if let imageUrl3 = user?.imageUrl3, let url = URL(string: imageUrl3) {
                              
                //  Nuke.loadImage(with: url, into: self.image1Button)
                    SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                                 self.photoView.image3.image = image
                    }
                }
           
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEditPhoto))
           
        photoView.addGestureRecognizer(photoTapGesture)
           
        tableView.tableHeaderView = photoView
        tableView.tableFooterView = UIView()
    }
    
    @objc fileprivate func handleEditPhoto() {
        let editPhotoController = EditPhotoController()
        editPhotoController.user = user
        navigationController?.pushViewController(editPhotoController, animated: true)
    }
    
        func configureUI() {
            configureTableView()
            
    //      navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = "Edit Profile"

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
                self.user = User(dictionary: dictionary)
                self.loadPhotos()
                self.tableView.reloadData()
            }
          
        }
            
}


extension NiceEditProfile: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return EditSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 7
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 0
        }
    
//        guard let section = EditSection(rawValue: section) else {return 0}
//     switch section {
//
//        case .Profile:
//            return ProfileOptions.allCases.count
//        case .Location:
//            return LocationMatchingOptions.allCases.count
//        case .VenueLocation:
//            return VenueOptions.allCases.count
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let view = UIView()
              view.backgroundColor = .white
              let title = UILabel()
              title.font = UIFont.boldSystemFont(ofSize: 22)
              title.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
              title.text = EditSection(rawValue: section)?.description
              view.addSubview(title)
              title.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 2, left: 10, bottom: 2, right: 0))
              return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = EditSection(rawValue: indexPath.section) else {return UITableViewCell()}

        switch section {

               case .Profile:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                 let profile = ProfileOptions(rawValue: indexPath.row)
                 cell.sectionType = profile
                cell.selectionStyle = .none
                 switch indexPath.row {
                case 0:
                    cell.titleText.text = "Name"
                    cell.userText.text = "\(user?.firstName ?? "Edit") \(user?.lastName ?? "Name")"
                     return cell
                        case 1:
                            cell.titleText.text = "School"
                            cell.userText.text = user?.school ?? "Edit School"
                            print(cell.titleText.text ?? "fuck")
                     return cell
                        case 2:
                            cell.titleText.text = "Occupation"
                            cell.userText.text = user?.occupation ?? "Edit Occupation"
                     return cell
                        case 3:
                            cell.titleText.text = "Age"
                            cell.userText.text = "\(user?.age ?? 18)"
                     return cell
                        case 4:
                            cell.titleText.text = "Bio"
                            cell.userText.text = user?.bio ?? "Edit Bio"
                     return cell
                        case 5:
                            cell.titleText.text = "Gender"
                            cell.userText.text = user?.gender ?? "Edit Gender"
                     return cell
                        case 6:
                            cell.titleText.text = "Gender Preference"
                            cell.userText.text = user?.sexPref ?? "Edit Gender Preference"
                    return cell
                 default:
                    cell.textLabel?.text = "Edit"
                    return cell
            }

               case .Location:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                    let location = LocationMatchingOptions(rawValue: indexPath.row)
                    cell.sectionType = location
                    cell.selectionStyle = .none
          
                switch indexPath.row {
                case 0:
                   cell.titleText.text = "Min Seeking Age"
                   cell.userText.text = "\(user?.minSeekingAge ?? 18) Years Old"
                    return cell
                case 1:
                    cell.titleText.text = "Max Seeking Age"
                    cell.userText.text = "\(user?.maxSeekingAge ?? 50) Years Old"
                    return cell
                case 2:
                    cell.titleText.text = "Max Distance"
                    cell.userText.text = "\(user?.maxDistance ?? 10) Miles"
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                    cell.textLabel?.text = "Edit"
                    return cell
            }
            

        case .VenueLocation:

            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                    let venue = VenueOptions(rawValue: indexPath.row)
                    cell.sectionType = venue
                    cell.selectionStyle = .none
                    cell.titleText.text = "Venue Distance"
                cell.userText.text = "\(user?.maxVenueDistance ?? 4) Miles"
                    return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                           let venue = VenueOptions(rawValue: indexPath.row)
                           cell.sectionType = venue
                cell.selectionStyle = .none
                cell.titleText.text = "Current Venue"
//                if user?.currentVenue != nil{
                cell.userText.text = user?.currentVenue ?? "None"
                //}
//                else {
//                    cell.userText.text = "None"
//                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                cell.textLabel?.text = "Edit"
                return cell
            }
               }
    }
    
    @objc fileprivate func handleMaxChangedDistance (slider: UISlider) {
         evaluateMinMaxDistance()
     }
    
    @objc fileprivate func handleMinChanged (slider: UISlider) {
        evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxChanged (slider: UISlider) {
        evaluateMinMax()
    }
    
    fileprivate func evaluateMinMaxDistance() {
        guard let locationRangeCell = tableView.cellForRow(at: [8, 0]) as? LocationTableViewCell else { return }
        //let minValue = Int(locationRangeCell.minSlider.value)
        //locationRangeCell.minLabel.text = "Min \(minValue)"
        let maxValue = locationRangeCell.evaluateMaxDistance()
        user?.maxDistance = maxValue
    }
    
    fileprivate func evaluateMinMax() {
        guard let ageRangeCell = tableView.cellForRow(at: [7, 0]) as? AgeRangeTableViewCell else { return }
        let minValue = ageRangeCell.evaluateMin()
        let maxValue = ageRangeCell.evaluateMax()
        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = EditSection(rawValue: indexPath.section) else {return}

        switch section {

           case .Profile:
             switch indexPath.row {
            case 0:
                   let nameController = EditNameController()
                        nameController.user = user
                        nameController.delegate = self
                         self.navigationController?.pushViewController(nameController, animated: true)
                    case 1:
                        let editSchoolController = EditSchoolController()
                        editSchoolController.user = user
                        editSchoolController.delegate = self
                        self.navigationController?.pushViewController(editSchoolController, animated: true)
                    case 2:
                        let occupationController = EditOccupationController()
                        occupationController.user = user
                        occupationController.delegate = self
                        self.navigationController?.pushViewController(occupationController, animated: true)
             case 3:
                let ageController = EditAgeController()
                ageController.user = user
                ageController.delegate = self
                self.navigationController?.pushViewController(ageController, animated: true)
                    case 4:
                        let editbio = EditBioController()
                        editbio.user = user
                        editbio.delegate = self
                        self.navigationController?.pushViewController(editbio, animated: true)
                    case 5:
                        let editGender = EditGenderController()
                        editGender.user = user
                        editGender.delegate = self
                        self.navigationController?.pushViewController(editGender, animated: true)
                    case 6:
                    let editSexPref = EditSexPrefController()
                    editSexPref.user = user
                    editSexPref.delegate = self
                    self.navigationController?.pushViewController(editSexPref, animated: true)
                                        
             default:
                print("No")
        }

    
        case .Location:
            
        switch indexPath.row {
            case 0:
                let ageSliderController = EditMinAgeSliderController()
                ageSliderController.user = user
                ageSliderController.delegate = self
                self.navigationController?.pushViewController(ageSliderController, animated: true)
            case 1:
                let ageSliderController = EditMinAgeSliderController()
                ageSliderController.user = user
                ageSliderController.delegate = self
                self.navigationController?.pushViewController(ageSliderController, animated: true)
        case 2:
            let distanceSlideController = EditMaxDistanceController()
            distanceSlideController.user = user
            distanceSlideController.delegate = self
            self.navigationController?.pushViewController(distanceSlideController, animated: true)
        default:
            print("yo")
            }
        case .VenueLocation:
            switch indexPath.row {
            case 0:
               let distanceSlideController = EditVenueDistanceController()
                distanceSlideController.user = user
               distanceSlideController.delegate = self
                self.navigationController?.pushViewController(distanceSlideController, animated: true)
            case 1:
                 if user?.currentVenue != "" {
                               let userbarController = UsersInBarTableView()
                               userbarController.barName = user?.currentVenue ?? ""
                               userbarController.user = user
                               userbarController.verb = "(Joined)"
                               let myBackButton = UIBarButtonItem()
                               myBackButton.title = " "
                               self.navigationItem.backBarButtonItem = myBackButton
                               self.navigationController?.pushViewController(userbarController, animated: true)
                               }
            default:
                print("Yo")
            }
        }
 
    }


}
