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

class NiceEditProfile: UIViewController {
    
private let reuseIdentifier = "NiceEditProfileCell"
    
       override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    var photoView: PhotoView!

    var tableView: UITableView!
    
    var user: User?
    
    // MARK: - Init

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
        
        tableView.tableHeaderView = photoView
        tableView.tableFooterView = UIView()
        
        
    }
    
        func configureUI() {
            configureTableView()
            
    //      navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = "Edit Profile"

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
            return 2
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
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
         let section = EditSection(rawValue: indexPath.section)

        switch section {
        case .Profile:
            return 60
        case .Location:
            if indexPath.row == 0 {
                return 100
            }
            else {
                return 70
            }
        case .VenueLocation:
                 if indexPath.row == 0 {
                       return 70
                   }
                   else {
                       return 60
                   }
        default:
            return 0
            }

        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
       
        title.text = EditSection(rawValue: section)?.description
        view.addSubview(title)
        title.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 3, left: 5, bottom: 5, right: 0))
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = EditSection(rawValue: indexPath.section) else {return UITableViewCell()}

        switch section {

               case .Profile:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                 let profile = ProfileOptions(rawValue: indexPath.row)
                 cell.sectionType = profile
                 switch indexPath.row {
                case 0:
                    cell.titleText.text = "Name"
                    cell.userText.text = user?.name ?? "Edit Name"
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
          
                switch indexPath.row {
                case 0:
                    let ageRangeCell = AgeRangeTableViewCell(style: .default, reuseIdentifier: nil)
                    ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinChanged), for: .valueChanged)
                    ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxChanged), for: .valueChanged)
                    ageRangeCell.setup(minSeekingAge: user?.minSeekingAge, maxSeekingAge: user?.maxSeekingAge)
                    return ageRangeCell
                case 1:
                    let locationRangeCell = LocationTableViewCell(style: .default, reuseIdentifier: nil)
                    locationRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxChangedDistance), for: .valueChanged)
                    locationRangeCell.setup(maxDistance: user?.maxDistance)
                    return locationRangeCell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
                    cell.textLabel?.text = "Edit"
                    return cell
            }
            

        case .VenueLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NiceEditProfileCell
            let venue = VenueOptions(rawValue: indexPath.row)
            cell.sectionType = venue
            return cell
               }
     return UITableViewCell()
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
                 let profile = ProfileOptions(rawValue: indexPath.row)
        case .Location:
            let location = LocationMatchingOptions(rawValue: indexPath.row)
    
        case .VenueLocation:
            let venueLocation = VenueOptions(rawValue: indexPath.row)
        }
    }
 
    
}


