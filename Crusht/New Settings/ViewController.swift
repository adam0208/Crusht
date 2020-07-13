//
//  ViewController.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

private let reuseIdentifier = "SettingsCell"

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    
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
        tableView.rowHeight = 60
        
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 800)
        
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 85)
        userInfoHeader = UserInfoHeader(frame: frame)
        userInfoHeader.usernameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
        userInfoHeader.schoolLabel.text = user?.school
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
                     //  Nuke.loadImage(with: url, into: self.image1Button)
                       SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                          self.userInfoHeader.profileImageView.image = image
                       }
                   }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
        userInfoHeader.addGestureRecognizer(tapRecognizer)
        
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
        
        
    }
    
    @objc fileprivate func goToProfile() {
        let userDetailsController = CurrentUserDetailsNoReportController()
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        navigationItem.backBarButtonItem = myBackButton
        userDetailsController.cardViewModel = user?.toCardViewModel()
        navigationController?.pushViewController(userDetailsController, animated: true)
    }
    
    func configureUI() {
        configureTableView()
        
//      navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Settings"
         navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))
    }
    
    @objc fileprivate func handleBack() {
          dismiss(animated: true)
      }
    
    @objc fileprivate func handleSwitchNotification(sender: UISwitch) {
          if sender.isOn {
              showSettingsAlert(sender: sender)
          }
          else {
              showSettingsAlert(sender: sender)
          }
      }
      
      @objc fileprivate func handleSwitchLocation(sender: UISwitch) {
          if sender.isOn {
              showSettingsAlert2(sender: sender)
          }
          else {
              showSettingsAlert2(sender: sender)
          }
      }
      
      private func showSettingsAlert(sender: UISwitch) {
          let alert = UIAlertController(title: "Notifications Permissions", message: "Change your notifications permissions?", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          })
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
              sender.isOn = false
              return
          })
          present(alert, animated: true)
      }
      
      private func showSettingsAlert2(sender: UISwitch) {
          let alert = UIAlertController(title: "Location Permissions", message: "Change your location permissions?", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          })
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
              sender.isOn = false
              return
          })
          present(alert, animated: true)
      }
      
    
    
}
    

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingsSection(rawValue: section) else {return 0}
        switch section {
        case .Social:
            return SocialOptions.allCases.count
        case .Communications:
            return CommunicationOptions.allCases.count
        case .About:
            return AboutOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 22)
        title.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        title.text = SettingsSection(rawValue: section)?.description
        view.addSubview(title)
        title.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 2, left: 10, bottom: 2, right: 0))
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {return UITableViewCell()}

        switch section {
               case .Social:
                 let social = SocialOptions(rawValue: indexPath.row)
                 cell.sectionType = social
               case .Communications:
                let communications = CommunicationOptions(rawValue: indexPath.row)
                cell.sectionType = communications
                switch communications {
                case .location:
                      switch CLLocationManager.authorizationStatus()  {
                        case .notDetermined, .restricted, .denied:
                        cell.switchControl.isOn = false
                        cell.switchControl.addTarget(self, action: #selector(handleSwitchLocation), for: .valueChanged)
                        default:
                        cell.switchControl.isOn = true
                        cell.switchControl.addTarget(self, action: #selector(handleSwitchLocation), for: .valueChanged)
                        }
                default:
                    let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                    if isRegisteredForRemoteNotifications {
                        cell.switchControl.isOn = true
                        cell.switchControl.addTarget(self, action: #selector(handleSwitchNotification), for: .valueChanged)
                    } else {
                        cell.switchControl.isOn = false
                        cell.switchControl.addTarget(self, action: #selector(handleSwitchNotification), for: .valueChanged)
                    }
                }
              
        case .About:
            let about = AboutOptions(rawValue: indexPath.row)
            cell.sectionType = about
               }

        cell.selectionStyle = .none
        return cell
    }
    
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else {return}

        switch section {
                case .Social:
                  let social = SocialOptions(rawValue: indexPath.row)
                  if social?.description == "Edit Profile" {
                    let settingsController = NiceEditProfile()
                    settingsController.user = user
                    let myBackButton = UIBarButtonItem()
                    myBackButton.title = " "
                    self.navigationItem.backBarButtonItem = myBackButton
                    self.navigationController?.pushViewController(settingsController, animated: true)
                }
                  else if social?.description == "Logout" {
                    let firebaseAuth = Auth.auth()
                        let loginViewController = LoginViewController()
                        let navController = UINavigationController(rootViewController: loginViewController)
                        navController.modalPresentationStyle = .fullScreen
                        do {
                            try firebaseAuth.signOut()
                        } catch { }
                        present(navController, animated: true)
                  }
                case .Communications:
                 let communications = CommunicationOptions(rawValue: indexPath.row)
        case .About:
            let about = AboutOptions(rawValue: indexPath.row)
            if about?.description == "Privacy" {
                let privacyCon = PrivacyController()
                self.navigationController?.pushViewController(privacyCon, animated: true)
            }
            else if about?.description == "Terms of Use" {
                let termsController = TermsViewController()
                self.navigationController?.pushViewController(termsController, animated: true)
            }
        }
    }
 
    
}

